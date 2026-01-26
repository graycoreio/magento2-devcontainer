# Magento 2 DevContainer

This devcontainer provides a complete development environment for Magento 2 that meets [Adobe's official system requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements).

## Supported Versions

This environment will support all of the currently supported Magento versions. There are multiple configurations available (one for each major version of Magento).

| Magento Version | Configuration                                               |
| --------------- | ----------------------------------------------------------- |
| v2.4.6          | [compose/2.4.6/docker-compose.yml](compose/2.4.6/docker-compose.yml)   |
| v2.4.7          | [compose/2.4.7/docker-compose.yml](compose/2.4.7/docker-compose.yml)   |
| v2.4.8          | [compose/2.4.8/docker-compose.yml](compose/2.4.8/docker-compose.yml)   |
| v2.4.9          | [compose/2.4.9/docker-compose.yml](compose/2.4.9/docker-compose.yml)   |
| next            | [compose/next/docker-compose.yml](compose/next/docker-compose.yml)     |
| latest          | [compose/latest/docker-compose.yml](compose/latest/docker-compose.yml) |

## Getting Started

1. Add this repository as a git submodule to your Magento project:

   ```bash
   git submodule add https://github.com/graycoreio/magento2-devcontainer.git .devcontainer/magento2-devcontainer
   ```

2. Copy the sample devcontainer.json to your project:

   ```bash
   cp .devcontainer/magento2-devcontainer/devcontainer.json.sample .devcontainer/devcontainer.json
   ```

3. Open the project in VS Code and click "Reopen in Container" when prompted.

## Additional Resources

- [Magento 2 DevDocs](https://developer.adobe.com/commerce/docs/)
- [Magento Release Notes](https://experienceleague.adobe.com/docs/commerce-operations/release/notes/overview.html)
- [System Requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements)
