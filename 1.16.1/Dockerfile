FROM endial/ubuntu:18.04

ENV APP_MAJOR       1.16.1 \
	PCRE_VERSION        8.43 \
	OPENSSL_VERSION     1.1.1e \
	HTTP_FLV_VERSION    1.2.7
#ENV APP_KEYS        B0F4253373F8F6F510D42178520A9993A1C052F8

LABEL \
	"Version"="v${APP_MAJOR}" \
	"Description"="Docker image for Nginx ${APP_MAJOR} based on Ubuntu 18.04." \
	"Dockerfile"="https://github.com/endial/docker-nginx" \
	"Vendor"="Endial Fang (endial@126.com)"

RUN set -eux; \
# 确保程序使用静默安装，而非交互模式
	export DEBIAN_FRONTEND=noninteractive; \
	groupadd -r nginx; \
	useradd -r -g nginx -s /usr/sbin/nologin -d /usr/cache/nginx nginx; \
	\
	mkdir -p /etc/nginx /srv/conf/nginx /var/log/nginx /var/run/nginx /var/cache/nginx; \
	\
	NGINX_CONFIG=" \
		--prefix=/etc/nginx \
		--user=nginx \
		--group=nginx \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--http-log-path=/var/log/nginx/access.log \
		--error-log-path=/var/log/nginx/error.log \
		--modules-path=/usr/lib/nginx/modules \
		--pid-path=/var/run/nginx/nginx.pid \
		--lock-path=/var/run/nginx/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        \
        --with-pcre=./pcre-$PCRE_VERSION \
		--with-pcre-jit \
		--add-module=./nginx-http-flv-module-$HTTP_FLV_VERSION \
		--with-http_flv_module \
		--with-openssl=./openssl-$OPENSSL_VERSION \
		--with-http_ssl_module \
		--with-http_v2_module \
		--with-http_realip_module \
		--with-http_xslt_module \
		--with-http_image_filter_module \
		--with-http_geoip_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_auth_request_module \
		--with-http_slice_module \
		\
		--with-stream \
		--with-stream_geoip_module \
		--with-stream_realip_module \
		--with-stream_ssl_module \
		--with-threads \
		--with-poll_module \
		--with-mail \
	"; \
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
		libxml2-dev \
		libxslt-dev \
		libgd-dev \
		libc6-dev \
		libgeoip-dev \
		libterm-readkey-perl \
	"; \
	apt-get update; \
	apt-get install -y ${fetchDeps}; \
	\
	apt install -y --no-install-recommends \
		zlib1g \
		libxml2 \
		libxslt1.1 \
		geoip-bin \
		geoip-database \
		libgd3 \
		libc6 \
	; \
	\
	wget -O nginx.tar.gz "http://nginx.org/download/nginx-${APP_MAJOR}.tar.gz"; \
	wget -O nginx.tar.gz.asc "http://nginx.org/download/nginx-${APP_MAJOR}.tar.gz.asc"; \
#	wget -O nginx_signing.key "https://nginx.org/keys/nginx_signing.key"; \
	\
	wget -O openssl.tar.gz --no-check-certificate "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz"; \
	wget -O openssl.tar.gz.asc --no-check-certificate "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz.asc"; \
	\
	wget -O pcre.tar.gz --no-check-certificate "https://nchc.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz"; \
	wget -O pcre.tar.gz.sig --no-check-certificate "https://nchc.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz.sig"; \
	\
	wget -O nginx-http-flv.tar.gz --no-check-certificate "https://github.com/winshining/nginx-http-flv-module/archive/v${HTTP_FLV_VERSION}.tar.gz"; \
	\
# verify the signature
#	export GNUPGHOME="$(mktemp -d)"; \
##	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys ${APP_KEYS}; \
#	gpg --import nginx_signing.key; \
#	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz; \
#	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
#	rm -r "$GNUPGHOME" nginx.tar.gz.asc; \
#	apt-key list; \
	\
	mkdir -p nginx-${APP_MAJOR}; \
	tar -xzvf nginx.tar.gz -C nginx-${APP_MAJOR} --strip-components 1; \
	rm -rf nginx.tar.gz nginx.tar.gz.asc nginx_signing.key; \
	mkdir -p nginx-${APP_MAJOR}/pcre-${PCRE_VERSION}; \
	tar -xzvf pcre.tar.gz -C nginx-${APP_MAJOR}/pcre-${PCRE_VERSION} --strip-components 1; \
	rm -rf pcre.tar.gz pcre.tar.gz.sig; \
	mkdir -p nginx-${APP_MAJOR}/openssl-${OPENSSL_VERSION}; \
	tar -xzvf openssl.tar.gz -C nginx-${APP_MAJOR}/openssl-${OPENSSL_VERSION} --strip-components 1; \
	rm -rf openssl.tar.gz openssl.tar.gz.asc; \
	mkdir -p nginx-${APP_MAJOR}/nginx-http-flv-module-${HTTP_FLV_VERSION}; \
	tar -xzvf nginx-http-flv.tar.gz -C nginx-${APP_MAJOR}/nginx-http-flv-module-${HTTP_FLV_VERSION} --strip-components 1; \
	rm -rf nginx-http-flv.tar.gz; \
	\
	cd nginx-${APP_MAJOR}; \
	./configure ${NGINX_CONFIG}; \
	make -j "$(nproc)"; \
	make install; \
	\
	echo "<?php" >/etc/nginx/html/index.php; \
	echo "phpinfo();" >>/etc/nginx/html/index.php; \
	echo "?>" >>/etc/nginx/html/index.php; \	
	\
	strip $(which nginx); \
	\
	cd /; \
	rm -rf /nginx-${APP_MAJOR}; \
	ln -sf /srv/conf/nginx/nginx.conf /etc/nginx/nginx.conf; \
	chown -Rf nginx:nginx /etc/nginx /srv/conf/nginx /var/log/nginx /var/run/nginx /var/cache/nginx; \
# this 777 will be replaced by 700 or 755 at runtime (allows semi-arbitrary "--user" values)
	chmod 777 /etc/nginx /srv/conf/nginx /var/log/nginx /var/run/nginx /var/cache/nginx; \
	\
	apt purge -y --auto-remove ${fetchDeps}; \
	apt autoclean -y; \
	rm -rf /var/lib/apt/lists/*;


COPY entrypoint.sh /usr/local/bin/
COPY ./nginx /etc/nginx

VOLUME ["/srv/www", "/srv/conf", "/srv/cert", "/var/log", "/var/run"]

# 解决使用gosu后，nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
EXPOSE 8080 8443

STOPSIGNAL SIGTERM

ENTRYPOINT ["entrypoint.sh"]

CMD ["nginx"]
