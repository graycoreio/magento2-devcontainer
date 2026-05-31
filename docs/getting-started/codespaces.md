# Using in GitHub Codespaces

If your repository already has the devcontainer configured, you can open it in GitHub Codespaces with zero local setup.

## Prerequisites

- A GitHub account with access to [Codespaces](https://github.com/features/codespaces)
- A repository with the devcontainer already configured

## Steps

1. Navigate to your repository on GitHub

2. Click **Code** → **Codespaces** → **Create codespace on main**

3. Wait for the environment to build

   On create, the devcontainer runs `composer install` automatically when the
   project's dependencies resolve from auth-free repositories (e.g.
   `mirror.mage-os.org`), and then runs `setup:install` automatically once the
   dependencies are in place. You get a ready-to-use store with no manual steps.

   If the project depends on license-gated repositories such as
   `repo.magento.com` or Hyvä, `composer install` is **skipped** unless
   credentials are available (and `setup:install` is skipped with it). Add a
   [`COMPOSER_AUTH` Codespaces secret](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-your-account-specific-secrets-for-github-codespaces)
   (or commit an `auth.json`) and rebuild, or run the manual steps in step 4.

4. (Only if the automatic install was skipped) Install dependencies and run setup:

```bash
composer install
.devcontainer/magento2-devcontainer/bin/setup-install.sh | bash
```

5. Verify the installation:

```bash
bin/magento --version
```

## Next Steps

- [Docker Compose Configuration](/customization/docker-compose) - Customize your environment
