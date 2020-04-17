FROM --platform=linux/amd64 endial/ubuntu:v18.04

LABEL \
	"Version"="v1.16.1" \
	"Description"="Docker image for Nginx 1.16.1 based on Ubuntu 18.04." \
	"Dockerfile"="https://github.com/endial/docker-libs" \
	"Vendor"="Endial Fang (endial@126.com)"

ENV NGINX_VERSION       1.16.1
ENV NGINX_GPG_KEYS      B0F4253373F8F6F510D42178520A9993A1C052F8
ENV PCRE_VERSION        8.43
ENV OPENSSL_VERSION     1.1.1e
ENV HTTP_FLV_VERSION    1.2.7

RUN set -eux; \
    groupadd -g 1001 nginx; \
    useradd -M -g nginx -s /usr/sbin/nologin -u 1001 nginx; \
    \
    NGINX_CONFIG=" \
        --with-pcre=./pcre-$PCRE_VERSION \
        --with-openssl=./openssl-$OPENSSL_VERSION \
        --add-module=./nginx-http-flv-module-$HTTP_FLV_VERSION \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-stream \
        --prefix=/etc/nginx \
        --user=nginx \
        --group=nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --modules-path=/usr/lib/nginx/modules \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
    "; \
    \
    fetchDeps=" \
        autoconf \
        automake \
        gcc \
        g++ \
        gcc-multilib \
        make \
        ca-certificates \
        wget \
        gpg \
        gpg-agent \
        dirmngr \
        zlib1g-dev \
    "; \
    apt update; \
    apt install -y --no-install-recommends $fetchDeps; \
    apt install -y --no-install-recommends zlib1g; \
    \
    wget -O nginx.tar.gz "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"; \
    wget -O nginx.tar.gz.asc "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc"; \
    wget -O nginx_signing.key "https://nginx.org/keys/nginx_signing.key"; \
    \
    wget -O openssl.tar.gz --no-check-certificate "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz"; \
    wget -O openssl.tar.gz.asc --no-check-certificate "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz.asc"; \
    \
    wget -O pcre.tar.gz --no-check-certificate "https://nchc.dl.sourceforge.net/project/pcre/pcre/$PCRE_VERSION/pcre-$PCRE_VERSION.tar.gz"; \
    wget -O pcre.tar.gz.sig --no-check-certificate "https://nchc.dl.sourceforge.net/project/pcre/pcre/$PCRE_VERSION/pcre-$PCRE_VERSION.tar.gz.sig"; \
    \
    wget -O nginx-http-flv.tar.gz --no-check-certificate "https://github.com/winshining/nginx-http-flv-module/archive/v$HTTP_FLV_VERSION.tar.gz"; \
# verify the signature
#    export GNUPGHOME="$(mktemp -d)"; \
##    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys $NGINX_GPG_KEYS; \
#    gpg --import nginx_signing.key; \
#    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz; \
#    command -v gpgconf > /dev/null && gpgconf --kill all || :; \
#    rm -r "$GNUPGHOME" nginx.tar.gz.asc; \
    \
    mkdir -p nginx-$NGINX_VERSION; \
    tar -xzvf nginx.tar.gz -C nginx-$NGINX_VERSION --strip-components 1; \
    rm -rf nginx.tar.gz nginx.tar.gz.asc; \
    mkdir -p nginx-$NGINX_VERSION/pcre-$PCRE_VERSION; \
    tar -xzvf pcre.tar.gz -C nginx-$NGINX_VERSION/pcre-$PCRE_VERSION --strip-components 1; \
    rm -rf pcre.tar.gz pcre.tar.gz.sig; \
    mkdir -p nginx-$NGINX_VERSION/openssl-$OPENSSL_VERSION; \
    tar -xzvf openssl.tar.gz -C nginx-$NGINX_VERSION/openssl-$OPENSSL_VERSION --strip-components 1; \
    rm -rf openssl.tar.gz openssl.tar.gz.asc; \
    mkdir -p nginx-$NGINX_VERSION/nginx-http-flv-module-$HTTP_FLV_VERSION; \
    tar -xzvf nginx-http-flv.tar.gz -C nginx-$NGINX_VERSION/nginx-http-flv-module-$HTTP_FLV_VERSION --strip-components 1; \
    rm -rf nginx-http-flv.tar.gz; \
    \
    cd nginx-$NGINX_VERSION; \
    ./configure $NGINX_CONFIG; \
    make -j "$(nproc)"; \
    make install; \
    \
    strip $(which nginx); \
    \
    cd /; \
    rm -rf /nginx-$NGINX_VERSION; \
    apt-get autoremove -y $fetchDeps; \
    rm -rf /var/lib/apt/lists/*; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log;


COPY entrypoint.sh /usr/local/bin/
COPY ./nginx /etc/nginx/

VOLUME ["/srv/www", "/srv/conf", "/srv/cert", "/var/log", "/var/run"]
EXPOSE 80 443

STOPSIGNAL SIGTERM

ENTRYPOINT ["entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;", "-c", "/srv/conf/nginx/nginx.conf"]
