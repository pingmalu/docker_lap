# docker_lap
Linux apache php Docker集成环境

# docker

构建

    docker build -t ml .

启动

    docker run -p 80:80 -v /app:/app -h ml --name ml -d ml:latest

重启apache

    docker exec -it ml /bin/bash -c '/etc/init.d/apache2 reload'

进入容器

    docker exec -it ml /bin/bash

## 快速重新部署


docker stop ml
docker rm ml
docker rmi ml:latest
docker build -t ml .
docker run -p 80:80 -v /app:/app -h ml --name ml -d ml:latest
curl http://ml.localhost/api

# composer

## 安装依赖包，并取消php版本检查

    composer install --ignore-platform-reqs

