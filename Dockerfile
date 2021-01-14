# Ver: 1.6 by Endial Fang (endial@126.com)
#

# 可变参数 ========================================================================

# 设置当前应用名称及版本
ARG app_name=nginx
ARG app_version=1.18.0

# 设置默认仓库地址，默认为 阿里云 仓库
ARG registry_url="registry.cn-shenzhen.aliyuncs.com"

# 设置 apt-get 源：default / tencent / ustc / aliyun / huawei
ARG apt_source=aliyun

# 编译镜像时指定用于加速的本地服务器地址
ARG local_url=""

# 预处理 =========================================================================
FROM ${registry_url}/colovu/dbuilder as builder

ARG app_name
ARG app_version
ARG registry_url
ARG apt_source
ARG local_url

# 选择软件包源(Optional)，以加速后续软件包安装
RUN select_source ${apt_source};

# 安装依赖的软件包及库(Optional)
RUN install_pkg autoconf automake gcc-multilib

RUN install_pkg	zlib1g-dev zlib1g \
		libxml2-dev libxml2 \
		libxslt1-dev libxslt1.1 \
		libgd-dev libgd3 \
		libc6-dev libc6 \
		libgeoip-dev geoip-bin geoip-database \
		libterm-readkey-perl 

ENV OPENSSL_VERSION=1.1.1e
ENV PCRE_VERSION=8.44
ENV HTTP_FLV_VERSION=1.2.7

# 设置工作目录
WORKDIR /usr/local

# 下载并解压软件包 openssl
RUN set -eux; \
	appName="openssl-${OPENSSL_VERSION}.tar.gz"; \
	[ ! -z ${local_url} ] && localURL=${local_url}/openssl; \
	appUrls="${localURL:-} \
		https://www.openssl.org/source/old/1.1.1 \
		"; \
	download_pkg unpack ${appName} "${appUrls}"; 

# 下载并解压软件包 pcre
RUN set -eux; \
	appName="pcre-${PCRE_VERSION}.tar.gz"; \
	[ ! -z ${local_url} ] && localURL=${local_url}/pcre; \
	appUrls="${localURL:-} \
		https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION} \
		https://jaist.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION} \
		"; \
	download_pkg unpack ${appName} "${appUrls}"; 

# 下载并解压软件包 flv
RUN set -eux; \
	appName="v${HTTP_FLV_VERSION}.tar.gz"; \
	[ ! -z ${local_url} ] && localURL=${local_url}/nginx-http-flv; \
	appUrls="${localURL:-} \
		https://github.com/winshining/nginx-http-flv-module/archive \
		"; \
	download_pkg unpack ${appName} "${appUrls}"; 

# 下载并解压软件包 nginx
RUN set -eux; \
	appName="${app_name}-${app_version}.tar.gz"; \
	[ ! -z ${local_url} ] && localURL=${local_url}/nginx; \
	appUrls="${localURL:-} \
		http://nginx.org/download \
		"; \
	download_pkg unpack ${appName} "${appUrls}"; 

# 源码编译: 编译后将配置文件模板拷贝至 /usr/local/${app_name}/share/${app_name} 中
RUN set -eux; \
	APP_SRC="/usr/local/${app_name}-${app_version}"; \
	cd ${APP_SRC}; \
	./configure \
		--prefix=/etc/nginx \
		--user=nginx \
		--group=nginx \
		--sbin-path=/usr/local/nginx/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--http-log-path=/var/log/nginx/access.log \
		--error-log-path=/var/log/nginx/error.log \
		--modules-path=/usr/local/nginx/modules \
		--pid-path=/var/run/nginx/nginx.pid \
		--lock-path=/var/run/nginx/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		\
		--with-pcre=/usr/local/pcre-$PCRE_VERSION \
		--with-pcre-jit \
		--add-module=/usr/local/nginx-http-flv-module-$HTTP_FLV_VERSION \
		--with-http_flv_module \
		--with-openssl=/usr/local/openssl-$OPENSSL_VERSION \
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
		; \
	make -j "$(nproc)"; \
	make install; \
	strip /usr/local/nginx/sbin/nginx;

# 生成默认 PHP 首页文件
RUN set -eux; \
	echo "<?php" >/etc/nginx/html/index.php; \
	echo "phpinfo();" >>/etc/nginx/html/index.php; \
	echo "?>" >>/etc/nginx/html/index.php;

# 检测并生成依赖文件记录
RUN set -eux; \
	find /usr/local/${app_name} -type f -executable -exec ldd '{}' ';' | \
		awk '/=>/ { print $(NF-1) }' | \
		sort -u | \
		xargs -r dpkg-query --search | \
		cut -d: -f1 | \
		sort -u >/usr/local/${app_name}/runDeps;


# 镜像生成 ========================================================================
FROM ${registry_url}/colovu/debian:10

ARG app_name
ARG app_version
ARG registry_url
ARG apt_source
ARG local_url

# 镜像所包含应用的基础信息，定义环境变量，供后续脚本使用
ENV APP_NAME=${app_name} \
	APP_USER=nginx \
	APP_EXEC=nginx \
	APP_VERSION=${app_version}

ENV	APP_HOME_DIR=/usr/local/${APP_NAME} \
	APP_DEF_DIR=/etc/${APP_NAME}

ENV PATH="${APP_HOME_DIR}/bin:${APP_HOME_DIR}/sbin:${PATH}" \
	LD_LIBRARY_PATH="${APP_HOME_DIR}/lib"

LABEL \
	"Version"="v${app_version}" \
	"Description"="Docker image for ${app_name}(v${app_version})." \
	"Dockerfile"="https://github.com/colovu/docker-${app_name}" \
	"Vendor"="Endial Fang (endial@126.com)"

# 拷贝应用使用的客制化脚本，并创建对应的用户及数据存储目录
COPY customer /
RUN create_user && prepare_env

# 从预处理过程中拷贝软件包(Optional)，可以使用阶段编号或阶段命名定义来源
COPY --from=0 /usr/local/${APP_NAME}/ /usr/local/${APP_NAME}
COPY --from=0 /etc/${APP_NAME}/ /etc/${APP_NAME}

COPY ./nginx /etc/nginx

# 选择软件包源(Optional)，以加速后续软件包安装
RUN select_source ${apt_source}

# 安装依赖的软件包及库(Optional)
RUN install_pkg `cat /usr/local/${APP_NAME}/runDeps`; 

# 执行预处理脚本，并验证安装的软件包
RUN set -eux; \
	override_file="/usr/local/overrides/overrides-${APP_VERSION}.sh"; \
	[ -e "${override_file}" ] && /bin/bash "${override_file}"; \
	gosu ${APP_USER} ${APP_EXEC} -V ; \
	gosu --version;

# 默认提供的数据卷
VOLUME ["/srv/conf", "/srv/data", "/srv/cert", "/var/log"]

# 默认使用gosu切换为新建用户启动，必须保证端口在1024之上
EXPOSE 8080 8443

# 容器初始化命令，默认存放在：/usr/local/bin/entry.sh
ENTRYPOINT ["entry.sh"]

# 应用程序的服务命令，必须使用非守护进程方式运行。如果使用变量，则该变量必须在运行环境中存在（ENV可以获取）
CMD ["${APP_EXEC}", "-c", "${APP_CONF_FILE}"]
