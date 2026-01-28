# Magento 2 DevContainer

This devcontainer provides a complete development environment for Magento 2 that meets [Adobe's official system requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements).

## Prerequisites

- [VSCode](https://code.visualstudio.com/) (or an editor that supports devcontainers)
- [Docker](https://www.docker.com/products/docker-desktop/)
- [Github Codespaces](https://github.com/features/codespaces) (Optional)

## Supported Versions

This environment will support all of the currently supported Magento versions. There are multiple configurations available (one for each major version of Magento).

| Magento Version | Configuration                                               |
| --------------- | ----------------------------------------------------------- |
| v2.4.6          | [compose/2.4.6/docker-compose.yml](compose/2.4.6/docker-compose.yml)   |
| v2.4.7          | [compose/2.4.7/docker-compose.yml](compose/2.4.7/docker-compose.yml)   |
| v2.4.8          | [compose/2.4.8/docker-compose.yml](compose/2.4.8/docker-compose.yml)   |
| v2.4.9          | [compose/2.4.9/docker-compose.yml](compose/2.4.9/docker-compose.yml)   |

## Getting Started

1. Make a .devcontainer folder in your project

```bash
mkdir -p .devcontainer
```

2. Add this repository as a git submodule to your Magento project:

```bash
git submodule add https://github.com/graycoreio/magento2-devcontainer.git .devcontainer/magento2-devcontainer
```

3. Run the `init` script 

```bash
/bin/bash .devcontainer/magento2-devcontainer/bin/init.sh
```

> [!INFO]
> If you're on Windows (and not using WSL2) and don't have access to bash, you can simply get away with copying the sample
> `devcontainer.json.sample`, `docker-compose.overrides.yml` and making a simple `docker-compose.yml` with the following content into your .devcontainer folder:

```yml
services: {}
```

4. (Optional) Run the `setup` script
```bash
/bin/bash .devcontainer/magento2-devcontainer/bin/setup-install.sh
```

5. Open the project in VS Code and click "Reopen in Container" when prompted.

## Additional Resources

- [Magento 2 DevDocs](https://developer.adobe.com/commerce/docs/)
- [Magento Release Notes](https://experienceleague.adobe.com/docs/commerce-operations/release/notes/overview.html)
- [System Requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements)
