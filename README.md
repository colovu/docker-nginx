# Nginx Ubuntu

基于的 Ubuntu(v1.16.1) 系统的 Nginx 镜像，用于提供 WEB(nginx) 服务。



## 基本信息

* 镜像地址：endial/nginx:v1.16.1
  * 依赖镜像：endial/ubuntu:v18.04



## 数据卷

镜像默认提供以下数据卷定义：

```shell
 /srv/www			# 站点源文件
 /srv/conf		# nginx 配置文件，配置文件存放在 nginx 子目录中
 /var/log			# 日志文件，nginx 日志存放在子目录 nginx 中
 /var/run			# 进程运行PID文件
```

如果需要持久化存储相应数据，需要在宿主机建立本地目录，并在使用镜像初始化容器时进行映射。

举例：

- 使用宿主机`/opt/conf`存储配置文件
- 使用宿主机`/srv/data`存储数据文件
- 使用宿主机`/srv/log`存储日志文件

创建以上相应的宿主机目录后，容器启动命令中对应的映射参数类似如下：

```dockerfile
-v /host/dir/to/conf:/srv/conf -v /host/dir/to/data:/srv/data -v /host/dir/to/log:/var/log
```

> 注意：应用需要使用的子目录会自动创建。



## 使用说明



### 运行容器

生成并运行一个新的容器：

```bash
docker run -d --name nginx \
  -p 80:8080 \
  -v /host/dir/to/www:/srv/www:ro \
  -v /host/dir/to/log:/var/log \
  -v /host/dir/to/conf:/srv/conf \
  endial/nginx:v1.16.1
```

使用宿主机用户（如`www-data`用户）生成新的容器：

```shell
docker run -d --name nginx \
	--user www-data \
  -p 80:8080 \
  -v /host/dir/to/www:/srv/www:ro \
  -v /host/dir/to/log:/var/log \
  -v /host/dir/to/conf:/srv/conf \
  endial/nginx:v1.16.1
```

> 注意：如果使用自定义用户创建容器，且需要使用数据卷，可以有两种方式确保权限正确：
>
> - 指定数据卷目录中不存在nginx子目录，由容器创建对应nginx目录及配置文件，然后个性化修改
> - 指定数据卷目录中存在nginx子目录，需要确保子目录及目录中文件属于启动容器时所指定的用户组

如果存在`dvc`数据容器，可以使用以下命令：

```bash
docker run -d --name nginx \
  -p 80:8080 \
  --volumes-from dvc \
  endial/nginx:v1.16.1
```



### 进入容器

使用容器ID或启动时的命名（本例中命名为`php-fpm`）进入容器：

```shell
docker exec -it nginx /bin/bash
```



### 停止容器

使用容器ID或启动时的命名（本例中命名为`php-fpm`）停止：

```shell
docker stop nginx
```



## 注意事项

- 容器中启动参数不能配置为后台运行，只能使用前台运行方式，即：`daemonize no`
- 如果应用使用后台方式运行，则容器的启动命令会在运行后自动退出，从而导致容器退出



----

本文原始来源 [Endial Fang](https://github.com/endial) @ [Github.com](https://github.com)

