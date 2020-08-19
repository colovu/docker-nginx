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
ENV APP_NAME=nginx \
	APP_EXEC=nginx \
	APP_VERSION=${app_ver}

# 定义应用基础目录信息，该常量在容器内可使用
ENV	APP_HOME_DIR=/usr/local/${APP_NAME} \
	APP_DEF_DIR=/etc/${APP_NAME} \
	APP_CONF_DIR=/srv/conf/${APP_NAME} \
	APP_DATA_DIR=/srv/data/${APP_NAME} \
	APP_DATA_LOG_DIR=/srv/datalog/${APP_NAME} \
	APP_CACHE_DIR=/var/cache/${APP_NAME} \
	APP_RUN_DIR=/var/run/${APP_NAME} \
	APP_LOG_DIR=/var/log/${APP_NAME} \
	APP_CERT_DIR=/srv/cert/${APP_NAME}

LABEL \
	"Version"="v${app_ver}" \
	"Description"="Docker image for ${APP_NAME}(v${app_ver})." \
	"Dockerfile"="https://github.com/colovu/docker-${APP_NAME}" \
	"Vendor"="Endial Fang (endial@126.com)"

# 拷贝默认 Shell 脚本至容器相关目录中
COPY prebuilds /

# 镜像内相应应用及依赖软件包的安装脚本；以下脚本可按照不同需求拆分为多个段，但需要注意各个段在结束前需要清空缓存
RUN \
# 设置程序使用静默安装，而非交互模式；默认情况下，类似 tzdata/gnupg/ca-certificates 等程序配置需要交互
	export DEBIAN_FRONTEND=noninteractive; \
	\
# 设置 shell 执行参数，分别为 -e(命令执行错误则退出脚本) -u(变量未定义则报错) -x(打印实际待执行的命令行)
	set -eux; \
	\
# 更改源为当次编译指定的源
	cp /etc/apt/sources.list.${apt_source} /etc/apt/sources.list; \
	\
# 为应用创建对应的组、用户、相关目录
	export OPENSSL_VERSION=1.1.1e; \
	export PCRE_VERSION=8.43; \
	export HTTP_FLV_VERSION=1.2.7; \
	export APP_DIRS="${APP_DEF_DIR:-} ${APP_CONF_DIR:-} ${APP_DATA_DIR:-} ${APP_CACHE_DIR:-} ${APP_RUN_DIR:-} ${APP_LOG_DIR:-} ${APP_CERT_DIR:-} ${APP_DATA_LOG_DIR:-} ${APP_HOME_DIR:-${APP_DATA_DIR}}"; \
	mkdir -p ${APP_DIRS}; \
	groupadd -r -g 998 ${APP_NAME}; \
	useradd -r -g ${APP_NAME} -u 999 -s /usr/sbin/nologin -d ${APP_DATA_DIR} ${APP_NAME}; \
	\
# 应用软件包及依赖项。相关软件包在镜像创建完成时，不会被清理
	appDeps=" \
		curl \
		ca-certificates \
		\
		zlib1g \
		libxml2 \
		libxslt1.1 \
		geoip-bin \
		geoip-database \
		libgd3 \
		libc6 \
	"; \
	savedAptMark="$(apt-mark showmanual) ${appDeps}"; \
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
# 安装临时使用的软件包及依赖项。相关软件包在镜像创建完后时，会被清理
	fetchDeps=" \
		wget \
		ca-certificates \
		\
		apt-transport-https \
		lsb-release \
		\
		autoconf \
		automake \
		gcc \
		g++ \
		gcc-multilib \
		make \
		\
		dirmngr \
		gnupg \
		\
		zlib1g-dev \
		libxml2-dev \
		libxslt-dev \
		libgd-dev \
		libc6-dev \
		libgeoip-dev \
		libterm-readkey-perl \
	"; \
	apt update; \
	apt upgrade -y; \
	apt install -y --no-install-recommends ${fetchDeps}; \
	\
	\
	\
# 下载需要的软件包资源。可使用 不校验、签名校验、SHA256 校验 三种方式
	DIST_NAME="${APP_NAME}-${APP_VERSION}.tar.gz"; \
	DIST_KEYIDS="0xB0F4253373F8F6F510D42178520A9993A1C052F8"; \
	DIST_URLS=" \
		${local_url}${APP_NAME}/ \
		http://nginx.org/download/ \
		"; \
	. /usr/local/scripts/libdownload.sh && download_dist "${DIST_NAME}" "${DIST_URLS}" --pgpkey "${DIST_KEYIDS}"; \
	\
	APP_SRC=/usr/local/src/nginx-${APP_VERSION}; \
	mkdir -p ${APP_SRC}; \
	tar --extract --file "${DIST_NAME}" --directory "${APP_SRC}" --strip-components 1; \
	rm -rf "${DIST_NAME}"; \
	\
	\
	\
# 下载需要的软件包资源。可使用 不校验、签名校验、SHA256 校验 三种方式
	DIST_NAME="openssl-${OPENSSL_VERSION}.tar.gz"; \
	DIST_URLS=" \
		${local_url}openssl/ \
		https://www.openssl.org/source/old/1.1.1/ \
		"; \
	. /usr/local/scripts/libdownload.sh && download_dist "${DIST_NAME}" "${DIST_URLS}"; \
	\
	APP_SRC=/usr/local/src/nginx-${APP_VERSION}/openssl-${OPENSSL_VERSION}; \
	mkdir -p ${APP_SRC}; \
	tar --extract --file "${DIST_NAME}" --directory "${APP_SRC}" --strip-components 1; \
	rm -rf "${DIST_NAME}"; \
	\
	\
	\
# 下载需要的软件包资源。可使用 不校验、签名校验、SHA256 校验 三种方式
	DIST_NAME="pcre-${PCRE_VERSION}.tar.gz"; \
	DIST_URLS=" \
		${local_url}/pcre/ \
		https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/ \
		https://jaist.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/ \
		"; \
	. /usr/local/scripts/libdownload.sh && download_dist "${DIST_NAME}" "${DIST_URLS}"; \
	\
	APP_SRC=/usr/local/src/nginx-${APP_VERSION}/pcre-${PCRE_VERSION}; \
	mkdir -p ${APP_SRC}; \
	tar --extract --file "${DIST_NAME}" --directory "${APP_SRC}" --strip-components 1; \
	rm -rf "${DIST_NAME}"; \
	\
	\
	\
# 下载需要的软件包资源。可使用 不校验、签名校验、SHA256 校验 三种方式
	DIST_NAME="v${HTTP_FLV_VERSION}.tar.gz"; \
	DIST_URLS=" \
		${local_url}nginx-http-flv/ \
		https://github.com/winshining/nginx-http-flv-module/archive/ \
		"; \
	. /usr/local/scripts/libdownload.sh && download_dist "${DIST_NAME}" "${DIST_URLS}"; \
	\
	APP_SRC=/usr/local/src/nginx-${APP_VERSION}/nginx-http-flv-module-${HTTP_FLV_VERSION}; \
	mkdir -p ${APP_SRC}; \
	tar --extract --file "${DIST_NAME}" --directory "${APP_SRC}" --strip-components 1; \
	rm -rf "${DIST_NAME}"; \
	\
	\
	\
# 源码编译方式安装: 编译后将原始配置文件拷贝至 ${APP_DEF_DIR} 中
	cd /usr/local/src/nginx-${APP_VERSION}; \
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
	rm -rf /usr/local/src/nginx-${APP_VERSION}; \
#	ln -sf /srv/conf/nginx/nginx.conf /etc/nginx/nginx.conf; \
	\
# 设置应用关联目录的权限信息
	chown -Rf ${APP_NAME}:${APP_NAME} ${APP_DIRS}; \
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
	apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps}; \
	apt autoclean -y; \
	rm -rf /var/lib/apt/lists/*; \
	:;

# 拷贝应用专用 Shell 脚本至容器相关目录中
COPY customer /

RUN set -eux; \
# 设置容器入口脚本的可执行权限
	chmod +x /usr/local/bin/entrypoint.sh; \
	\
# 检测是否存在对应版本的 overrides 脚本文件；如果存在，执行
	{ [ ! -e "/usr/local/overrides/overrides-${app_ver}.sh" ] || /bin/bash "/usr/local/overrides/overrides-${app_ver}.sh"; }; \
	\
# 验证安装的软件是否可以正常运行，常规情况下放置在命令行的最后
	gosu ${APP_NAME} ${APP_EXEC} -V ; \
	:;

COPY ./nginx /etc/nginx

# 默认提供的数据卷
VOLUME ["/srv/conf", "/srv/data", "/srv/cert", "/srv/datalog", "/var/log"]

# 默认使用gosu切换为新建用户启动，必须保证端口在1024之上
EXPOSE 8080 8443

STOPSIGNAL SIGTERM

# 容器初始化命令，默认存放在：/usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

WORKDIR ${APP_DATA_DIR}

# 应用程序的服务命令，必须使用非守护进程方式运行。如果使用变量，则该变量必须在运行环境中存在（ENV可以获取）
CMD ["${APP_EXEC}"]
