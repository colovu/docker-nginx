#!/bin/bash
# docker entrypoint script

# 以下变量已在 Dockerfile 中定义，不需要修改
# APP_NAME: 应用名称，nginx
# APP_EXEC: 应用可执行二进制文件，nginx
# APP_USER: 应用对应的用户名，nginx
# APP_GROUP: 应用对应的用户组名，nginx

set -Eeo pipefail

LOG_RAW() {
  local type="$1"; shift
  printf '%s [%s] Entrypoint: %s\n' "$(date --rfc-3339=seconds)" "$type" "$*"
}
LOG_I() {
  LOG_RAW Note "$@"
}
LOG_W() {
  LOG_RAW Warn "$@" >&2
}
LOG_E() {
  LOG_RAW Error "$@" >&2
  exit 1
}

LOG_I "Initial container for ${APP_NAME}"

# 检测当前脚本是被直接执行的，还是从其他脚本中使用 "source" 调用的
_is_sourced() {
  [ "${#FUNCNAME[@]}" -ge 2 ] \
    && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
    && [ "${FUNCNAME[1]}" = 'source' ]
}

# 使用root用户运行时，创建默认的数据目录，并拷贝所必须的默认配置文件及初始化文件
# 修改对应目录所属用户为应用对应的用户
# 使用--user指定用户时，挂载的数据卷及子目录下文件默认会映射会对应的用户，不用修改
docker_create_user_directories() {
  local user_id; user_id="$(id -u)"

  # 如果设置了'--user'，这里 user_id 不为 0
  # 如果没有设置'--user'，这里 user_id 为 0，需要使用默认用户名设置相关目录权限
  LOG_I "Check directories used by ${APP_NAME}"
  mkdir -p "/var/log/${APP_NAME}"
  mkdir -p "/var/run/${APP_NAME}"
  mkdir -p "/var/cache/${APP_NAME}"

  mkdir -p "/srv/conf/${APP_NAME}/conf.d"
  [ ! -e /srv/conf/nginx/nginx.conf ] && cp /etc/nginx/nginx.conf.default /srv/conf/nginx/nginx.conf
  [ ! -e /srv/conf/nginx/mime.types ] && cp /etc/nginx/mime.types /srv/conf/nginx/
  [ ! -e /srv/conf/nginx/conf.d/default.conf ] && cp /etc/nginx/conf.d/default.conf /srv/conf/nginx/conf.d/

  # 允许容器使用`--user`参数启动，修改相应目录的所属用户信息
  if [ "$user_id" = '0' ]; then
    LOG_I "Chang owner of resources to: ${APP_USER} by root"
    find /var/run/${APP_NAME} \! -user ${APP_USER} -exec chown ${APP_USER} '{}' +
    find /var/log/${APP_NAME} \! -user ${APP_USER} -exec chown ${APP_USER} '{}' +
    find /var/cache/${APP_NAME} \! -user ${APP_USER} -exec chown ${APP_USER} '{}' +
    find /srv/conf/${APP_NAME} \! -user ${APP_USER} -exec chown ${APP_USER} '{}' +
	chmod 755 /etc/nginx /var/log/nginx /var/cache/nginx /var/run/nginx /srv/conf/nginx 
# 解决使用gosu后，nginx: [emerg] open() "/dev/stdout" failed (13: Permission denied)
    chmod 0622 /dev/stdout /dev/stderr
  fi
}

# 检测可能导致容器执行后直接退出的命令，如"--help"；如果存在，直接返回 0
docker_app_want_help() {
  local arg
  for arg; do
    case "$arg" in
      -'?'|-h|-V|-v|-t|-T)
        return 0
        ;;
    esac
  done
  return 1
}

_main() {
  # 如果命令行参数是以配置参数("-")开始，修改执行命令，确保使用可执行应用命令启动服务器
  if [ "${1:0:1}" = '-' ]; then
    LOG_I "Add ${APP_EXEC} at the begin of command line"
    set -- ${APP_EXEC} "$@"
  fi

  # 命令行参数以可执行应用命令起始，且不包含直接返回的命令(如：-V、--version、--help)时，执行初始化操作
  if [ "$1" = "${APP_EXEC}" ] && ! docker_app_want_help "$@"; then

    # 以root用户运行时，设置数据存储目录与权限；设置完成后，会使用gosu重新以"postgres"用户运行当前脚本
    docker_create_user_directories
    if [ "$(id -u)" = '0' ]; then
      LOG_I "Restart container with default user: ${APP_USER}"
      LOG_I ""
      exec gosu ${APP_USER} "$0" "$@"
    fi
  fi
  
  LOG_I "Start container with: $@"

  # 执行命令行
  exec "$@"
}

if ! _is_sourced; then
  LOG_I "Run shell script with: $@"
  _main "$@"
fi
