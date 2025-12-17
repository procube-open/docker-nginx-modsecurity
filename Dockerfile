# ==============================================================================
# ModSecurity Builder Image
# 目的: Nginx互換のModSecurityモジュールとCRSをコンパイル/準備して保持しておく
# ==============================================================================
ARG NGINX_VERSION=1.29.2
FROM nginx:${NGINX_VERSION}

# 1. ビルドツールと依存ライブラリのインストール
RUN apt update && apt install -y \
    git build-essential libpcre2-dev zlib1g-dev libssl-dev \
    libxml2-dev libgeoip-dev libyajl-dev libcurl4-openssl-dev \
    liblmdb-dev libtool automake autoconf wget

# 2. ModSecurity (v3) のコンパイル
WORKDIR /opt
RUN git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity \
    && cd ModSecurity \
    && git submodule init && git submodule update \
    && ./build.sh && ./configure && make && make install

# 3. ModSecurity-nginx コネクタの準備
WORKDIR /opt
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

# 4. OWASP CRS の準備
WORKDIR /opt
RUN git clone --depth 1 https://github.com/coreruleset/coreruleset /opt/owasp-crs \
    && cp /opt/owasp-crs/crs-setup.conf.example /opt/owasp-crs/crs-setup.conf \
    && rm -rf /opt/owasp-crs/.git

# 5. 動的モジュール (.so) のコンパイル
# ベースイメージのNginxと全く同じバージョンのソースを使う必要がある
WORKDIR /opt
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar xzf nginx-${NGINX_VERSION}.tar.gz

WORKDIR /opt/nginx-${NGINX_VERSION}
RUN ./configure --with-compat --add-dynamic-module=/opt/ModSecurity-nginx \
    && make modules
