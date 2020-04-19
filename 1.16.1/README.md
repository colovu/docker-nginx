# Nginx Ubuntu

基于的 Ubuntu(v1.16.1) 系统的 Nginx 镜像，用于提供 WEB(nginx) 服务。



## 基本信息

* 镜像地址：endial/nginx-ubuntu:v1.16.1
* 依赖镜像：endial/ubuntu:v18.04



## 数据卷

```
 /srv/www			# 站点源文件
 /srv/conf			# nginx 配置文件，配置文件存放在 nginx 子目录中
 /var/log			# 日志文件，nginx 日志存放在子目录 nginx 中
 /var/run			# 进程运行PID文件，及Socket通讯文件
```



## 使用说明

定义环境变量：

```shell
# 确定数据卷存储位置，可使用分散的目录或集中存储
export DOCKER_VOLUME_BASE=</volumes/path>
```

- 注意修改主文件路径为实际路径



### 运行容器

生成并运行一个新的容器：

```bash
docker run -d --name nginx \
  -p 80:80 \
  -v $DOCKER_VOLUME_BASE/srv/www:/srv/www:ro \
  -v $DOCKER_VOLUME_BASE/var/log:/var/log \
  -v $DOCKER_VOLUME_BASE/srv/conf:/srv/conf \
  endial/nginx-ubuntu:v1.16.1
```

使用宿主机用户（如`www-data`用户生成新的容器：

```shell
docker run -d --name nginx \
	--user www-data \
  -p 80:80 \
  -v $DOCKER_VOLUME_BASE/srv/www:/srv/www:ro \
  -v $DOCKER_VOLUME_BASE/var/log:/var/log \
  -v $DOCKER_VOLUME_BASE/srv/conf:/srv/conf \
  endial/nginx-ubuntu:v1.16.1
```

> 注意：如果使用自定义用户创建容器，且需要使用数据卷，可以有两种方式确保权限正确：
>
> - 指定数据卷目录中不存在nginx子目录，由容器创建对应nginx目录及配置文件，然后个性化修改
> - 指定数据卷目录中存在nginx子目录，需要确保子目录及目录中文件属于启动容器时所指定的用户组

如果存在`dvc`数据容器，可以使用以下命令：

```bash
docker run -d --name nginx \
  -p 80:80 \
  --volumes-from dvc \
  endial/nginx-ubuntu:v1.16.1
```



----

本文原始来源 [Endial Fang](https://github.com/endial) @ [Github.com](https://github.com)

