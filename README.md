# Magento 2 DevContainer

This devcontainer provides a complete development environment for Magento 2 that meets [Adobe's official system requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements).

## Prerequisites

- [VSCode](https://code.visualstudio.com/) (or an editor that supports devcontainers)
- [Docker](https://www.docker.com/products/docker-desktop/)
- [Github Codespaces](https://github.com/features/codespaces) (Optional)

## Installed tools

### Devcontainer Features
- [Claude Code](https://code.claude.com/docs/en/overview)
- [Github CLI](https://cli.github.com/)

### Container built-ins
- [n98-magerun2](https://github.com/netz98/n98-magerun2)
- [composer](https://getcomposer.org/)
- [Xdebug](https://xdebug.org/)

## Supported Versions

This environment will support all of the currently supported Magento versions. There are multiple configurations available (one for each major version of Magento).

| Magento Version | Configuration                                               |
| --------------- | ----------------------------------------------------------- |
| v2.4.6          | [compose/2.4.6/docker-compose.yml](compose/2.4.6/docker-compose.yml)   |
| v2.4.7          | [compose/2.4.7/docker-compose.yml](compose/2.4.7/docker-compose.yml)   |
| v2.4.8          | [compose/2.4.8/docker-compose.yml](compose/2.4.8/docker-compose.yml)   |
| v2.4.9          | [compose/2.4.9/docker-compose.yml](compose/2.4.9/docker-compose.yml)   |

## Getting Started

See the [Getting Started Guide](https://devcontainer.mappia.io/getting-started.html).


## Additional Resources

- [Magento 2 DevDocs](https://developer.adobe.com/commerce/docs/)
- [Magento Release Notes](https://experienceleague.adobe.com/docs/commerce-operations/release/notes/overview.html)
- [System Requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements)
