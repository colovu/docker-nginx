# Nginx Alpine
基于的 Alpine(v3.11) 系统的 Nginx 镜像，用于提供 WEB(nginx) 服务。



## 基本信息

* 镜像地址：endial/nginx-alpine:v1.16.1
* 依赖镜像：endial/alpine:v3.11



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
  endial/nginx-alpine:v1.16.1
```


如果存在`dvc`数据容器，可以使用以下命令：

```bash
docker run -d --name nginx \
  -p 80:80 \
  --volumes-from dvc \
  endial/nginx-alpine:v1.16.1
```
