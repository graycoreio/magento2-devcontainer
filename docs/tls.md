# TLS Configuration

> **Note:** This configuration is only relevant when running devcontainers locally. If you're using GitHub Codespaces, HTTPS is handled automatically and you can skip this setup.

When working locally, it's important to consider the end-user experience. To mimic production as closely as possible for debugging purposes, you can setup a local TLS certificate. This devcontainer supports optional TLS (HTTPS) for local development.

## Configuration Options

Two nginx configurations are provided:

| Directory        | Description                       |
| ---------------- | --------------------------------- |
| `nginx/default/` | HTTP only (port 80)               |
| `nginx/tls/`     | HTTP (port 80) + HTTPS (port 443) |

## Enabling TLS

To enable TLS, modify your `docker-compose.overrides.yml` to:

1. Mount the TLS nginx config (as opposed to the default config)
2. Mount your certificates directory
3. Set the certificate filenames

```yaml
services:
  nginx:
    environment:
      - MAGENTO_TLS_CERT=magento2.test.pem
      - MAGENTO_TLS_KEY=magento2.test-key.pem
    volumes:
      - ./magento2-devcontainer/nginx/tls:/etc/nginx/templates
      - ./certs:/etc/nginx/certs
```

## Certificates

### Using Default Snakeoil Certificates

Default self-signed certificates are included in `magento2-devcontainer/certs/`:

- `snakeoil.crt`
- `snakeoil.key`

These work out of the box but will trigger browser security warnings.

```yaml
services:
  nginx:
    environment:
      - MAGENTO_TLS_CERT=snakeoil.crt
      - MAGENTO_TLS_KEY=snakeoil.key
    volumes:
      - ./magento2-devcontainer/nginx/tls:/etc/nginx/templates
      - ./magento2-devcontainer/certs:/etc/nginx/certs
```

### Using mkcert (Recommended)

[mkcert](https://github.com/FiloSottile/mkcert) generates locally-trusted certificates that work without browser warnings.

1. Install mkcert on your system:

   ```bash
   # macOS
   brew install mkcert

   # Linux
   sudo apt install mkcert
   # or
   sudo pacman -S mkcert

   # Windows
   choco install mkcert
   ```

2. Install the local CA (this registers mkcert's root certificate with your system):

   ```bash
   mkcert -install
   ```

3. Generate certificates for your domain and place them in the certs directory:

   ```bash
   YOUR_TEST_DOMAIN=magento2.test
   mkdir -p .devcontainer/magento2/certs
   cd .devcontainer/magento2/certs
   mkcert -key-file $YOUR_TEST_DOMAIN-key.pem -cert-file $YOUR_TEST_DOMAIN.pem $YOUR_TEST_DOMAIN
   ```

4. Update your `docker-compose.overrides.yml` with the cert filenames as shown above.

At this point, you should have a working TLS cert covering the `$YOUR_TEST_DOMAIN` domain.

## Environment Variables

| Variable           | Default        | Description                                  |
| ------------------ | -------------- | -------------------------------------------- |
| `MAGENTO_TLS_CERT` | `snakeoil.crt` | Certificate filename in `/etc/nginx/certs`   |
| `MAGENTO_TLS_KEY`  | `snakeoil.key` | Private key filename in `/etc/nginx/certs`   |

## Troubleshooting

### Browser still shows certificate warnings with mkcert

Make sure you ran `mkcert -install` before generating the certificates. If you generated certs first, delete them and regenerate after running the install command.

### Certificate not found errors

Verify that:

- The certs directory is mounted to `/etc/nginx/certs`
- The `MAGENTO_TLS_CERT` and `MAGENTO_TLS_KEY` environment variables match the actual filenames in your certs directory
