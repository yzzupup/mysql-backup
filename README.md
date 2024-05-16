# mysql-backup
自动备份指定ip的mysql数据库

## Dockerfile
构建了一个备份镜像，将所有的bash脚本都拷贝到了/app路径下面，通过entrypoint在容器启动时执行脚本

## docker-compose.yml
启动了一个mysql容器和一个备份容器

## 命令
docker compose up -d
