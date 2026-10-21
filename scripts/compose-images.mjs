#!/usr/bin/env node
// Revise the image tags in compose/<project>/<version>/docker-compose.yml
// from graycoreio/github-actions-magento2's supported-version data.
//
// Every compose dir must resolve to a version entry, and every service
// whose image the action tracks must agree on the image repository.
// Anything else fails the build; nothing is written on failure.

import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

const ROOT = resolve(import.meta.dirname, '..');
const COMPOSE_DIR = join(ROOT, 'compose');
const ACTION = join(ROOT, 'node_modules/@graycoreio/github-actions-magento2/supported-version/dist/index.js');

// compose/<dir> -> supported-version `project` input
const PROJECTS = {
  'magento': 'magento-open-source',
  'mage-os': 'mage-os',
  'mage-os-minimal': 'mage-os-minimal',
};

// image repository -> matrix entry field holding the image to use
const REPO_FIELDS = {
  'mappia/magento-php': 'php',
  'nginx': 'nginx',
  'mysql': 'mysql',
  'mariadb': 'mysql',
  'opensearchproject/opensearch': 'opensearch',
  'elasticsearch': 'elasticsearch',
  'rabbitmq': 'rabbitmq',
  'valkey/valkey': 'valkey',
  'redis': 'redis',
};

const splitImage = (image) => {
  const i = image.lastIndexOf(':');
  return i === -1 ? [image, ''] : [image.slice(0, i), image.slice(i + 1)];
};

// Run the action's bundled entrypoint outside a runner: inputs come from
// INPUT_* env vars and the matrix is written to GITHUB_OUTPUT.
const getMatrix = (project) => {
  const out = join(mkdtempSync(join(tmpdir(), 'supported-version-')), 'output');
  writeFileSync(out, '');
  execFileSync(process.execPath, [ACTION], {
    stdio: ['ignore', 'inherit', 'inherit'],
    env: {
      ...process.env,
      INPUT_KIND: 'all',
      INPUT_PROJECT: project,
      INPUT_CUSTOM_VERSIONS: '',
      INPUT_RECENT_TIME_FRAME: '',
      INPUT_INCLUDE_SERVICES: 'false',
      INPUT_SERVICE_PREFERENCES: '',
      GITHUB_OUTPUT: out,
    },
  });
  const m = readFileSync(out, 'utf8').match(/^matrix<<(\S+)\n([\s\S]*?)\n\1$/m);
  if (!m) throw new Error(`supported-version produced no matrix for ${project}`);
  return JSON.parse(m[2]).include;
};

const versionOf = (entry) => entry.magento.split(':')[1];
const baseVersion = (version) => version.replace(/-p\d+$/, '');
const patchOf = (version) => Number((version.match(/-p(\d+)$/) || [, 0])[1]);

// Newest entry on the same release line as the compose dir; patch
// releases share the stack of their base version.
const findEntry = (entries, version) =>
  entries
    .filter((e) => baseVersion(versionOf(e)) === version)
    .sort((a, b) => patchOf(versionOf(b)) - patchOf(versionOf(a)))[0];

const imageFor = (service, repo, tag, entry) => {
  const field = REPO_FIELDS[repo];
  if (!field) return null; // not tracked by the action (e.g. mailpit)

  if (field === 'php') {
    if (!/^devcontainer\d/.test(tag)) throw new Error(`${service}: unexpected tag ${tag}`);
    if (entry.php === undefined) throw new Error(`${service}: entry has no php version`);
    return `${repo}:devcontainer${entry.php}`;
  }

  const image = entry[field];
  if (!image) throw new Error(`${service}: entry has no ${field} image but compose uses ${repo}:${tag}`);
  const [entryRepo] = splitImage(image);
  if (entryRepo !== repo) throw new Error(`${service}: compose uses ${repo} but entry has ${image}`);
  return image;
};

const revise = (text, entry) => {
  const lines = text.split('\n');
  const seen = new Set();
  const errors = [];
  let service = null;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (/^\S/.test(line)) service = null;
    const svc = line.match(/^  ([\w-]+):\s*$/);
    if (svc) service = svc[1];
    const img = service && line.match(/^(\s+image:\s*)(\S+)(.*)$/);
    if (!img) continue;
    const [repo, tag] = splitImage(img[2]);
    let next;
    try {
      next = imageFor(service, repo, tag, entry);
    } catch (e) {
      errors.push(e.message);
      continue;
    }
    if (next === null) continue;
    seen.add(REPO_FIELDS[repo]);
    lines[i] = `${img[1]}${next}${img[3]}`;
  }
  for (const field of ['rabbitmq']) {
    if (entry[field] && !seen.has(field)) errors.push(`entry has ${entry[field]} but compose has no ${field} service`);
  }
  if (errors.length) throw new Error(errors.join('; '));
  return lines.join('\n');
};

const writes = [];
const failures = [];

for (const [dir, project] of Object.entries(PROJECTS)) {
  const entries = getMatrix(project);
  for (const version of readdirSync(join(COMPOSE_DIR, dir)).sort()) {
    const key = `${dir}/${version}`;
    const file = join(COMPOSE_DIR, key, 'docker-compose.yml');
    try {
      const entry = findEntry(entries, version);
      if (!entry) throw new Error(`no ${project} version matches ${version}`);
      const before = readFileSync(file, 'utf8');
      const after = revise(before, entry);
      console.log(`${key}: ${entry.magento}${after === before ? '' : ' (changed)'}`);
      if (after !== before) writes.push([file, after]);
    } catch (e) {
      failures.push(`${key}: ${e.message}`);
    }
  }
}

if (failures.length) {
  console.error('\nBuild failed:');
  for (const f of failures) console.error(`  ${f}`);
  process.exit(1);
}

for (const [file, text] of writes) writeFileSync(file, text);
