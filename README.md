编写这个的目标在于，构建一个「自动化」、「无干扰」、而且又能根据不同语言，动态设置代码检测和分析工具。

我们选择的环境和工具是：

> 版本控制：GitLab
> CI：GitLab-Runner
> Automated code review tool：reviewdog
> PHP Static Analysis Tool：phpstan (PHPStan requires PHP >= 7.1)
> 代码规范检测：PHP_CodeSniffer
> 

![](http://image.coding01.cn/2018/11/14/15421738648415.jpg)

## 构建 Docker image

构建该镜像主要是集成这些工具，然后把监测结果利用 reviewdog 输到 gitlab commit 上。

### reviewdog

> reviewdog - A code review dog who keeps your codebase healthy.
> 
> "reviewdog" provides a way to post review comments to code hosting service, such as GitHub, automatically by integrating with any linter tools with ease. It uses an output of lint tools and posts them as a comment if findings are in diff of patches to review.
> 
> reviewdog also supports run in the local environment to filter an output of lint tools by diff.
> 
> 官网：[https://github.com/haya14busa/reviewdog](https://github.com/haya14busa/reviewdog)


```
# 安装 reviewdog
ENV REVIEWDOG_VERSION 0.9.11

RUN wget -O /usr/local/bin/reviewdog -q https://github.com/haya14busa/reviewdog/releases/download/$REVIEWDOG_VERSION/reviewdog_linux_amd64 && \
    chmod +x /usr/local/bin/reviewdog
```

### phpstan

> PHP Static Analysis Tool - discover bugs in your code without running it!
> 
> 官网：[https://github.com/phpstan/phpstan](https://github.com/phpstan/phpstan)

```
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
```

### PHP_CodeSniffer

> PHP_CodeSniffer tokenizes PHP, JavaScript and CSS files and detects violations of a defined set of coding standards.
> 
> 官网：[https://github.com/squizlabs/PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)


```
# 安装 phpcs
ENV PHPCS_VERSION=2.9.2

RUN curl -L https://github.com/squizlabs/PHP_CodeSniffer/releases/download/$PHPCS_VERSION/phpcs.phar > /usr/local/bin/phpcs \
    && chmod +x /usr/local/bin/phpcs \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
```

### 配置

其中，每个工具都有一个配置文件，下面我们一个个理解。

*.reviewdog.yml*

创建 `REVIEWDOG_GITLAB_API_TOKEN` 值

## 总结

*参考*

> 1. Static analysis tools for PHP in a single docker image [http://zalas.eu/phpqa-static-analysis-tools-for-php-docker-image/](http://zalas.eu/phpqa-static-analysis-tools-for-php-docker-image/)