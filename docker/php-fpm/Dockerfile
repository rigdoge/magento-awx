FROM php:8.3-fpm

# 删除默认配置文件
RUN rm -f /usr/local/etc/php-fpm.d/www.conf \
    && rm -f /usr/local/etc/php-fpm.d/www.conf.default \
    && mkdir -p /run/php \
    && chown www-data:www-data /run/php \
    && chmod 755 /run/php

# 设置工作目录
WORKDIR /var/www/html

# 使用 www-data 用户运行
USER www-data 