# What is the Magento 2 Devcontainer?

A [devcontainer](https://containers.dev/) is a development environment that runs inside a Docker container. Instead of installing PHP, MySQL, OpenSearch, and other services directly on your machine, everything runs in isolated containers that are configured identically for every developer.

::: tip
If you're familiar with [`docker-compose`](https://docs.docker.com/compose/), devcontainers are essentially the same thing but instead of editing files located directly on your host machine, your editor and terminal operate on files directly inside one of the containers of your `docker-compose` environment. 
:::

## The Problem

Traditionally, installing Magento has two "startup" problems for developers:

1. Setting up Magento is difficult
2. As a result of 1, every environment has discrepancies between themselves.

### Setting up Magento is difficult

Setting up a local Magento development environment traditionally requires:

- [Installing the correct PHP version with 20+ extensions](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements#php-extensions)
- [Configuring several 3rd-party services that Magento requires to operate](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements)
  - Nginx or Apache
  - MySQL or MariaDB
  - OpenSearch or Elasticsearch
  - Redis or Valkey for caching and sessions
  - RabbitMQ for message queues

This setup isn't trivial, especially for developers coming from other language ecosystems. Even worse, this setup makes it exceedingly difficult for more junior team members to get started. Weeks of development effort are lost by senior engineers debugging team member environments as opposed to shipping new features.

### Environment discrepancies
 
Every developer is different. Every developer has a distinct operating system, on a distinct version, with distinct tools versions and preferences. As a result, every developer installs Magento differently, leading to "it works on my machine" issues. Version mismatches between local and production environments cause bugs that only appear after deployment.


## The Solution

This devcontainer packages the entire Magento stack into a reproducible configuration that can be applied to any [Magento](https://www.magento-opensource.com/) / [Adobe Commerce](https://business.adobe.com/products/commerce.html) / [MageOS](https://mage-os.org/) store.

When you open your store's project in [VS Code](https://code.visualstudio.com/) (or any editor that supports devcontainers), the devcontainer:

1. Pulls pre-configured Docker images
2. Starts all required services
3. Mounts your project code into the container
4. Connects your editor to the container's PHP runtime

## Benefits

### Consistency

Every developer gets the exact same environment. No more debugging configuration differences between machines.

### Production Parity

Service versions match [Adobe's official system requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements). If it works in the devcontainer, it will work in production.

### Zero Local Installation

Your host machine stays clean. No PHP installations to manage, no MySQL servers running in the background. Just Docker.

### Works in Codespaces

The same configuration works in [GitHub Codespaces](https://github.com/features/codespaces), giving you a cloud-hosted development environment accessible from any browser.

### Onboarding

New team members clone the repo, open in VS Code, and start coding. No setup documentation to follow or troubleshoot.

### Start debugging in minutes, not days

The devcontainer environment ships with Xdebug (and it's paired VS Code extension) installed and configured out of the box. This means that you can "step-through" debug Magento code immediately. No more "var_dump" debugging.

## How It Works

The devcontainer is defined by files in your `.devcontainer/` directory:

| File                        | Purpose                                                      | Committed |
| --------------------------- | ------------------------------------------------------------ | --------- |
| `devcontainer.json`         | VS Code settings, extensions, and container configuration    | Yes       |
| `docker-compose.yml`        | Sets the Docker Compose working directory                    | Yes       |
| `docker-compose.shared.yml` | Shared project-specific config (volumes, env vars)           | Yes       |
| `docker-compose.local.yml`  | Personal developer overrides (resource limits, extra mounts) | No        |
| `.env`                      | Environment variables for the services                       | No        |

The compose files are loaded in order, with later files overriding earlier ones. This the devcontainer core provide base configuration while your project customizes it.

When VS Code opens the project, it reads `devcontainer.json`, starts the Docker Compose services, and attaches to the PHP container as your development environment.