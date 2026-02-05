# Changelog

## 1.0.0 (2026-02-05)


### ⚠ BREAKING CHANGES

* remove bin/db/import.sh in favor of n98-magerun2 db:import

### Features

* add a db import script ([cfb7f8f](https://github.com/graycoreio/magento2-devcontainer/commit/cfb7f8fcad2b5d47d5da8b2bb5e6c465dbb86a51))
* add a sample .env ([075282b](https://github.com/graycoreio/magento2-devcontainer/commit/075282bf0ea1ba7a337cd8db8157ca3d036d0996))
* add claude code system req ([f9abca8](https://github.com/graycoreio/magento2-devcontainer/commit/f9abca880e413dd87ece3516a5494ea9f1ca340d))
* add claude to devcontainer ([880adf3](https://github.com/graycoreio/magento2-devcontainer/commit/880adf3c5a1ee60fc22db7ae2701f743699fb2b8))
* add configurations for local TLS ([87835cb](https://github.com/graycoreio/magento2-devcontainer/commit/87835cb369914655b2e84eaad809b3f894cfccb8))
* add system requirements for devcontainer ([3eb7121](https://github.com/graycoreio/magento2-devcontainer/commit/3eb7121a711636a7ccfa8c66b5f85adbb603e2a5))
* allow devcontainer discovery more than one folder deep ([d3d78a3](https://github.com/graycoreio/magento2-devcontainer/commit/d3d78a3831edc475bf551327e783ed1a04bd4f1f))
* change filesystem permissions during setup:install ([2072680](https://github.com/graycoreio/magento2-devcontainer/commit/207268056374a01cfceccf79bb7f7fc8d5d46824))
* hoist all branches into the main branch ([5f63792](https://github.com/graycoreio/magento2-devcontainer/commit/5f63792f1bb9b52d9314b0cb27166f6920c4c2d3))
* improve devx of initing the devcontainer ([8530e34](https://github.com/graycoreio/magento2-devcontainer/commit/8530e3431da44bf59d4731f804b59a17c45821f7))
* improve naming conventions for docker-compose ([837dcc3](https://github.com/graycoreio/magento2-devcontainer/commit/837dcc3fd1124f974112fdc45f443c63563c5201))
* init devcontainer ([6b7489d](https://github.com/graycoreio/magento2-devcontainer/commit/6b7489dec7c40a1baca06310e9d14099522dc3d1))
* init.sh compute available versions from static list ([fef07b7](https://github.com/graycoreio/magento2-devcontainer/commit/fef07b78105f3ae8ec4ba138399c1842add66570))
* install node using Corepack instead of Yarn APT to avoid GPG errors ([#2](https://github.com/graycoreio/magento2-devcontainer/issues/2)) ([4aa9871](https://github.com/graycoreio/magento2-devcontainer/commit/4aa9871566d4ea1ce8b38f2eae11cb3281c95703))
* make friendly-name versions of the yml ([65dee91](https://github.com/graycoreio/magento2-devcontainer/commit/65dee91023a01192e69849d34cdad0ee8d3b1df9))
* remove bin/db/import.sh in favor of n98-magerun2 db:import ([3729204](https://github.com/graycoreio/magento2-devcontainer/commit/372920441d3c92e4b69a4e184446b4cac88781d9))
* remove latest/next versions that don't work ([177c553](https://github.com/graycoreio/magento2-devcontainer/commit/177c553d161adb61103f674ae8439b6a32d11dbe))
* upgrade 2.4.8 deps from system requirements ([7168cba](https://github.com/graycoreio/magento2-devcontainer/commit/7168cbae33f96c94f441098ae05c791eb7f98577))
* upgrade 2.4.8 deps from system requirements ([7ac61fe](https://github.com/graycoreio/magento2-devcontainer/commit/7ac61fe3e78e76c96f3144408a61a7e8302a936f))
* use opensearch via CONFIG ([8bc590a](https://github.com/graycoreio/magento2-devcontainer/commit/8bc590af1bfad0a4371979119cdb019f7949173d))
* v2.4.6 - mysql:8.0, disable tls and enable log-bin-trust-function-creators ([1e62285](https://github.com/graycoreio/magento2-devcontainer/commit/1e622858ea8ff6520b386d00ed9d9166df8707fb))


### Bug Fixes

* adjust bad paths in dockerComposeFile ([342b677](https://github.com/graycoreio/magento2-devcontainer/commit/342b67796da8deaa4685455151c82fb90f8b1f27))
* adjust bad paths in dockerComposeFile ([0611158](https://github.com/graycoreio/magento2-devcontainer/commit/0611158bd2aeae50e8e73e848b06e149513f992f))
* remove bad workspaceFolder path in sample devcontainer ([ee649af](https://github.com/graycoreio/magento2-devcontainer/commit/ee649af344515f1a2031931aaa3e2f786b13d8e7))
* use appropriate mariadb version for 2.4.7 ([5ebef36](https://github.com/graycoreio/magento2-devcontainer/commit/5ebef36f82d42adbf2d775a668de5d4a83181c05))
