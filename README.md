# Magento 2 DevContainer

This devcontainer provides a complete development environment for Magento 2 that meets [Adobe's official system requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements).

## Version Branches

Each branch provides a docker-compose configuration matching the system requirements for that Magento version:

| Branch | Magento Version | Configuration |
|--------|-----------------|---------------|
| `main` | 2.4.9 | [docker-compose.yml](https://github.com/graycoreio/magento2-devcontainer/blob/main/docker-compose.yml) |
| `dev-v2.4.8` | 2.4.8 | [docker-compose.yml](https://github.com/graycoreio/magento2-devcontainer/blob/dev-v2.4.8/docker-compose.yml) |
| `dev-v2.4.7` | 2.4.7 | [docker-compose.yml](https://github.com/graycoreio/magento2-devcontainer/blob/dev-v2.4.7/docker-compose.yml) |
| `dev-v2.4.6` | 2.4.6 | [docker-compose.yml](https://github.com/graycoreio/magento2-devcontainer/blob/dev-v2.4.6/docker-compose.yml) |

To use a specific version, update your git submodule to the appropriate branch:

```bash
cd .devcontainer/magento2-devcontainer
git checkout dev-v2.4.7  # or desired branch
```

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
