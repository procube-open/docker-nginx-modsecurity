# Nginx + ModSecurity v3 Builder Image

This repository provides a Docker image containing pre-compiled binaries for **ModSecurity v3 (Libmodsecurity)**, the **ModSecurity-nginx connector**, and the **OWASP ModSecurity Core Rule Set (CRS)**.

It is designed to be used as a **Builder Stage** in multi-stage Docker builds. By using this image, you can significantly reduce the build time of your Nginx WAF container, as you no longer need to compile ModSecurity from source every time.

## Features

* **Base Image**: Nginx 1.29.2 (Debian 13 / Trixie based)
* **ModSecurity**: v3 (Master branch), compiled with PCRE2 support.
* **Connector**: ModSecurity-nginx connector (compiled as a dynamic module).
* **Rules**: OWASP ModSecurity Core Rule Set (CRS) included.
* **Ready-to-use**: Artifacts are located in standard paths for easy copying.

## How to Use

Use this image in your `Dockerfile` to copy the compiled artifacts (modules and configuration files).

```dockerfile
ARG NGINX_VERSION="1.29.2"

# Step 1: Resource Provider (This image)
FROM procube/nginx-modsec-builder:${NGINX_VERSION} AS builder

# Step 2: Runner (Your production image)
FROM nginx:${NGINX_VERSION}

# Install runtime dependencies (much lighter than build tools)
RUN apt update && apt install -y \
    libxml2 libyajl2 libgeoip1 liblmdb0 libcurl4 \
    && rm -rf /var/lib/apt/lists/*

# Copy artifacts from the builder
COPY --from=builder /usr/local/modsecurity /usr/local/modsecurity
COPY --from=builder /opt/nginx-${NGINX_VERSION}/objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/

# Copy configuration files
COPY --from=builder /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsecurity.conf
COPY --from=builder /opt/ModSecurity/unicode.mapping /etc/nginx/unicode.mapping
COPY --from=builder /opt/owasp-crs /etc/nginx/owasp-crs

# ... Add your nginx.conf and other settings here ...
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments & Credits

This Docker image is built upon several open-source projects. We are grateful to the communities behind them.

* **Nginx**: [2-clause BSD License](http://nginx.org/LICENSE)
* **ModSecurity**: [Apache License 2.0](https://github.com/SpiderLabs/ModSecurity/blob/v3/master/LICENSE)
* **ModSecurity-nginx**: [Apache License 2.0](https://github.com/SpiderLabs/ModSecurity-nginx/blob/master/LICENSE)
* **OWASP ModSecurity Core Rule Set (CRS)**: [Apache License 2.0](https://github.com/coreruleset/coreruleset/blob/main/LICENSE)

This project contains software developed by the ModSecurity project and the OWASP Core Rule Set project.
