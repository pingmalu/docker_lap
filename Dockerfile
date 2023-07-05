# 2022年8月 latest 对应 22.04 代号 jammy
# 20.04 代号 focal
FROM ubuntu:22.04
# 取消交互
ARG DEBIAN_FRONTEND=noninteractive

#时区设置
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app/www

# 使用国内源更新
RUN rm /bin/sh && ln -s /bin/bash /bin/sh \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse" > /etc/apt/sources.list \
    && sed -i -r 's#http://mirrors.aliyun.com#http://mirrors.ustc.edu.cn#g' /etc/apt/sources.list


# 另一种写法直接替换
# RUN sed -i -r 's#http://(archive|security).ubuntu.com#https://mirrors.aliyun.com#g' /etc/apt/sources.list \
# RUN echo "deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse\n\
# deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse\n\
# deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse\n\
# deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse" > /etc/apt/sources.list && \
# # 替换中科大
# sed -i -r 's#http://mirrors.aliyun.com#http://mirrors.ustc.edu.cn#g' /etc/apt/sources.list
# 替换163
# sed -i -r 's#http://mirrors.aliyun.com#http://mirrors.163.com#g' /etc/apt/sources.list
# 替换清华
# sed -i -r 's#http://mirrors.aliyun.com#http://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list

RUN apt update \
    # && apt install -y openssh-server vim apache2 php \
    # && apt install -y git zip unzip vim net-tools inetutils-ping curl iproute2 python3 python-is-python3 pip openssh-server apache2 php php-mongodb php-redis php-mysql php-pgsql php-curl php-mbstring php-gd \
    && apt install -y git zip unzip vim net-tools inetutils-ping curl iproute2 openssh-server apache2 php php-mongodb php-redis php-mysql php-pgsql php-curl php-mbstring php-gd \
    # redis \
    # pgloader \
    # heroku 没有icmp套接字权限
    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# RUN echo "<?php phpinfo();" > /var/www/html/php.php
# RUN mkdir /run/sshd
# config to enable .htaccess
COPY apache-ml.conf /etc/apache2/sites-available/apache-ml.conf
RUN a2enmod rewrite && a2enmod headers \
    && sed -i '/\/var\/www\//{N;N;s/AllowOverride None/AllowOverride all/}' /etc/apache2/apache2.conf \
    && sed -i 's/\/var\/www\//\/app\/www/' /etc/apache2/apache2.conf \
#    && sed -i 's/Listen 80/Listen 90/' /etc/apache2/ports.conf \
    && rm -rf /etc/apache2/sites-enabled/000-default.conf \
    && ln -s /etc/apache2/sites-available/apache-ml.conf /etc/apache2/sites-enabled/apache-ml.conf
#    && sed -i 's/bind 127.0.0.1 ::1/bind 0.0.0.0 ::/' /etc/redis/redis.conf 
# COPY apache-def.conf /etc/apache2/sites-available/000-default.conf
# RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php/8.1/apache2/php.ini
# RUN composer install
# ENV HOME /var/www/html
# RUN echo "d1" > /var/www/html/index.html && rm -rf /var/www/html/heroku.yml

# CMD ["/usr/sbin/sshd","-D"]
# CMD service redis-server start && \
# bash /app/.profile.d/heroku-exec.sh && \
# rm -rf /var/www/html/index.html && \
# sed -i "s/80/$PORT/g" /etc/apache2/sites-enabled/000-default.conf /etc/apache2/ports.conf && \
CMD apachectl -D FOREGROUND

