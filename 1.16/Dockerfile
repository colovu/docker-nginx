# Ver: 1.0 by Endial Fang (endial@126.com)
#
# 指定原始系统镜像，常用镜像为 colovu/ubuntu:18.04、colovu/debian:10、colovu/alpine:3.12、colovu/openjdk:8u252-jre
FROM colovu/debian:10

# ARG参数使用"--build-arg"指定，如 "--build-arg apt_source=tencent"
# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=default

# 外部指定应用版本信息，如 "--build-arg app_ver=6.0.0"
ARG app_ver=1.16.1

# 编译镜像时指定本地服务器地址，如 "--build-arg local_url=http://172.29.14.108/dist-files/"
ARG local_url=""

# 定义应用基础常量信息，该常量在容器内可使用
ENV APP_MAJOR=1.16.1 \
	PCRE_VERSION=8.43 \
	OPENSSL_VERSION=1.1.1e \
	HTTP_FLV_VERSION=1.2.7 \
	NGINX_KEYS='0xB0F4253373F8F6F510D42178520A9993A1C052F8'

LABEL \
	"Version"="v${APP_MAJOR}" \
	"Description"="Docker image for Nginx ${APP_MAJOR} based on Ubuntu 18.04." \
	"Dockerfile"="https://github.com/colovu/docker-nginx" \
	"Vendor"="Endial Fang (endial@126.com)"

# 镜像内应用安装脚本
# 以下脚本可按照不同需求拆分为多个段，但需要注意各个段在结束前需要清空缓存
# set -eux: 设置 shell 执行参数，分别为 -e(命令执行错误则退出脚本) -u(变量未定义则报错) -x(打印实际待执行的命令行)
RUN set -eux; \
	\
# 设置程序使用静默安装，而非交互模式；类似tzdata等程序需要使用静默安装
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
		--sbin-path=/usr/local/sbin/nginx \
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
	\
# 更新源，并安装临时使用的软件包（使用完后可删除）
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
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y ${fetchDeps}; \
	\
# 安装应用程序及需要依赖的软件包
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
	\
	wget -O openssl.tar.gz --no-check-certificate "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz"; \
	wget -O openssl.tar.gz.asc --no-check-certificate "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz.asc"; \
	\
	wget -O pcre.tar.gz --no-check-certificate "https://nchc.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz"; \
	wget -O pcre.tar.gz.sig --no-check-certificate "https://nchc.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz.sig"; \
	\
	wget -O nginx-http-flv.tar.gz --no-check-certificate "https://github.com/winshining/nginx-http-flv-module/archive/v${HTTP_FLV_VERSION}.tar.gz"; \
	\
# 安装软件包需要使用的GPG证书
	export GNUPGHOME="$(mktemp -d)"; \
	for key in ${NGINX_KEYS}; do \
		gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "${key}"|| \
		gpg --batch --keyserver pgp.mit.edu --recv-keys "${key}" || \
		gpg --batch --keyserver keys.gnupg.net --recv-keys "${key}" || \
		gpg --batch --keyserver keyserver.pgp.com --recv-keys "${key}"; \
	done; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz; \
	\
	command -v gpgconf > /dev/null && gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
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
	\
# 设置临时目录的权限信息，设置为777是为了保证后续使用`--user`或`gosu`时，可以更改目录对应的用户属性信息；运行时会被更改为700或755
	chown -Rf nginx:nginx /etc/nginx /srv/conf/nginx /var/log/nginx /var/run/nginx /var/cache/nginx; \
	chmod 777 /etc/nginx /srv/conf/nginx /var/log/nginx /var/run/nginx /var/cache/nginx; \
	\
# 查找新安装的应用及应用依赖软件包，并标识为'manual'，防止后续自动清理时被删除
	apt-mark auto '.*' > /dev/null; \
	{ [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; }; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual; \
	\
# 删除安装的临时依赖软件包，清理缓存
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps}; \
	apt-get autoclean -y; \
	rm -rf /var/lib/apt/lists/*; \
	\
# 验证安装的软件是否可以正常运行，常规情况下放置在命令行的最后
	: ;

COPY entrypoint.sh /usr/local/bin/
COPY ./nginx /etc/nginx

VOLUME ["/srv/www", "/srv/conf", "/srv/cert", "/var/log", "/var/run"]

# 解决使用gosu后，nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
# 默认使用gosu切换为新建用户启动，必须保证端口在1024之上
EXPOSE 8080 8443

STOPSIGNAL SIGTERM

# 容器初始化命令，默认存放在：/usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["nginx"]
