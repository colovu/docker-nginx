# Nginx

针对 [Nginx](http://nginx.org) 应用的 Docker 镜像，用于提供 Nginx 服务。容器详细使用说明可参考仓库：[Gitee](https://www.gitee.com/endial/studylife.git) 或 [Github](https://www.github.com/endial/studylife.git)中`服务器运维`相应文档。

使用说明可参照：[官方说明](http://nginx.org/en/docs/)

![logo-nginx](img/logo-nginx.png)

**版本信息：**

- 1.18、latest
- 1.16

**镜像信息：**

* 镜像地址：
  - 国内镜像仓库：registry.cn-shenzhen.aliyuncs.com/colovu/nginx
  - DockerHub：colovu/nginx



## TL;DR

Docker 快速启动命令：

```shell
# 从 Docker Hub 服务器下载镜像并启动
$ docker run -d -p 80:8080 colovu/nginx:1.18

# 从 Aliyun 服务器下载镜像并启动
$ docker run -d -p 80:8080 registry.cn-shenzhen.aliyuncs.com/colovu/nginx:1.18
```

- 后续相关命令行默认使用 Docker Hub 镜像服务器做说明



Docker-Compose 快速启动命令：

```shell
# 从 Gitee 下载 Compose 文件
$ curl -sSL -o https://gitee.com/colovu/docker-nginx/raw/master/docker-compose.yml

# 从 Github 下载 Compose 文件
$ curl -sSL -o https://raw.githubusercontent.com/colovu/docker-nginx/master/docker-compose.yml

# 创建并启动容器
$ docker-compose up -d
```



---



## 默认对外声明

### 端口

- 8080：HTTP 端口
- 8443：HTTPS 端口

### 数据卷

镜像默认提供以下数据卷定义，默认数据分别存储在自动生成的应用名对应`nginx`子目录中：

```shell
 /srv/data				# 站点源文件
 /srv/conf				# nginx 配置文件
 /var/log					# 日志文件
 /var/run					# 进程运行PID文件
```

如果需要持久化存储相应数据，需要**在宿主机建立本地目录**，并在使用镜像初始化容器时进行映射。宿主机相关的目录中如果不存在对应应用`nginx`的子目录或相应数据文件，则容器会在初始化时创建相应目录及文件。



## 容器配置

在初始化 `Nginx` 容器时，如果没有预置配置文件，可以在命令行中设置相应环境变量对默认参数进行修改。类似命令如下（配置环境变量`APP_ENV_KEY_NAME`的值为`key_value`）：

```shell
$ docker run -d -e "APP_ENV_KEY_NAME=key_value" colovu/nginx
```



### 自动变量替换

针对配置文件中的配置项，支持环境变量名自动替换，该类环境变量定义规则为：`APP_CFG_*=<val>`

- `APP_CFG_`：环境变量自动替换标识，具备该前缀的环境变量会被自动处理并更新至配置文件
- `*`：配置文件中对应的配置项名，大小写需要符合实际参数名要求；特殊字符需要符合`特殊字符替换规则`
- `<val>`：配置项对应值

例如：

```shell
# 设置配置文件中配置项 max_wal_size，传入容器的变量为(两者都可以)：
APP_CFG_max_wal_size=400MB
APP_CFG_max_wal_size="400MB"

# 容器启动后，应用配置文件中对应配置项生效，且设置为相应值：
max_wal_size = '400MB'
```

**特殊字符替换规则**：

- 针对使用`xml`格式的配置文件
    + `_` ==> `.` : 环境变量中的`下划线`会被转义为设置属性中的`半角点`
    + `__` ==> `_` : 环境变量中的`双下划线`会被转义为设置属性中的`单下划线`
    + `___` ==> `-` : 环境变量中的`三下划线`会被转义为设置属性中的`中划线`
- 针对使用`key-val`格式的配置文件
    + `_` ==> `_` : 环境变量中的`下划线`不会被替换
    + `__` ==> `.` : 环境变量中的`双下划线`会被转义为设置属性中的`半角点`
    + `___` ==> `-` : 环境变量中的`三下划线`会被转义为设置属性中的`中划线`


### 常规配置参数

常规配置参数用来配置容器基本属性，一般情况下需要设置，主要包括：

- 

### 常规可选参数

如果没有必要，可选配置参数可以不用定义，直接使用对应的默认值，主要包括：

- `ENV_DEBUG`：默认值：**false**。设置是否输出容器调试信息。可选值：1、true、yes

### 集群配置参数

配置服务为集群工作模式时，通过以下参数进行配置：

- 

### TLS配置参数

配置服务使用 TLS 加密时，通过以下参数进行配置：

- 



## 安全

### 容器安全

本容器默认使用应用对应的运行时用户及用户组运行应用，以加强容器的安全性。在使用非`root`用户运行容器时，相关的资源访问会受限；应用仅能操作镜像创建时指定的路径及数据。使用`Non-root`方式的容器，更适合在生产环境中使用。

如果需要赋予容器内应用访问外部设备的权限，可以使用以下两种方式：

- 启动参数增加`--privileged=true`选项
- 针对特定权限需要使用`--cap-add`单独增加特定赋权，如：ALL、NET_ADMIN、NET_RAW



## 注意事项

- 容器中应用的启动参数不能配置为后台运行，如果应用使用后台方式运行，则容器的启动命令会在运行后自动退出，从而导致容器退出



## 更新记录

- 2021/1/14(1.18): 更新为 Nginx 1.18.0
- 2021/1/1 (1.16): 初始版本，基于 Nginx 1.16.1  



----

本文原始来源 [Endial Fang](https://github.com/colovu) @ [Github.com](https://github.com)

