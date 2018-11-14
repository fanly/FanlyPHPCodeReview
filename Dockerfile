FROM alpine:3.7

LABEL maintainer="fanly <yemeishu@126.com>"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# Set timezone to CST
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk update && \
    apk upgrade && \
    apk add --nocache ca-certificates wget bash git openssh && \
    update-ca-certificates

# https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# 安装 reviewdog
ENV REVIEWDOG_VERSION 0.9.11

RUN wget -O /usr/local/bin/reviewdog -q https://github.com/haya14busa/reviewdog/releases/download/$REVIEWDOG_VERSION/reviewdog_linux_amd64 && \
    chmod +x /usr/local/bin/reviewdog

# 安装 phpstan
ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH /composer/vendor/bin:$PATH

RUN apk add curl \
    php7 \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fileinfo \
    php7-ftp \
    php7-iconv \
    php7-json \
    php7-mbstring \
    php7-mysqlnd \
    php7-openssl \
    php7-pdo \
    php7-pdo_sqlite \
    php7-phar \
    php7-posix \
    php7-session \
    php7-simplexml \
    php7-sqlite3 \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-zlib \
    && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('/tmp/composer-setup.php');" \
    && php -r "unlink('/tmp/composer-setup.sig');" \
    && echo "memory_limit=-1" > /etc/php7/conf.d/99_memory-limit.ini \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

# 安装 phpcs
ENV PHPCS_VERSION=2.9.2

RUN curl -L https://github.com/squizlabs/PHP_CodeSniffer/releases/download/$PHPCS_VERSION/phpcs.phar > /usr/local/bin/phpcs \
    && chmod +x /usr/local/bin/phpcs \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
