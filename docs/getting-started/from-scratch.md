# Starting from Scratch

Start a new Magento project with the devcontainer when you don't have an existing codebase.

## Prerequisites

- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker](https://www.docker.com/products/docker-desktop/)

## Steps

1. Clone the [starter project from GitHub](https://github.com/graycoreio/magento2-devcontainer-starter)

```bash
git clone git@github.com:graycoreio/magento2-devcontainer-starter.git
```

<details>
<summary>Alternative: manual setup without the starter project</summary>

If you don't want to use the starter project, you can initialize your store manually (this assumes that you have a unix shell):

```bash
mkdir my-magento-store && cd my-magento-store
git init
mkdir -p .devcontainer
git submodule add https://github.com/graycoreio/magento2-devcontainer.git .devcontainer/magento2-devcontainer
.devcontainer/magento2-devcontainer/bin/init.sh
```

</details>

2. Open in VS Code and click **Reopen in Container** when prompted.

3. Create the Magento project inside the container:

```bash
composer create-project \
  --repository-url=https://mirror.mage-os.org/ \
  magento/project-community-edition /tmp/magento

cp -r /tmp/magento/. /workspace/
rm -rf /tmp/magento
```

4. Run setup:

```bash
.devcontainer/magento2-devcontainer/bin/setup-install.sh | bash
```

5. Verify the installation:

```bash
bin/magento --version
```

## Next Steps

- [Docker Compose Configuration](/customization/docker-compose) - Customize your environment
- [TLS Setup](/customization/tls) - Enable HTTPS for local development
