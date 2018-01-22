FROM ubuntu:16.04
LABEL maintainer="jimmy.dai@program.com.tw"
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=C.UTF-8

WORKDIR /var/www

# 增加 apt-get 套件來源
RUN \
    apt-get -qq update && \
    apt-get install -y software-properties-common curl && \
    # 加入 php 套件來源
    add-apt-repository -y ppa:ondrej/php && \
    # 加入 nodejs 套件來源 (這個會幫你執行 apt-get update)
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    # 加入 yarn 套件來源
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get -qq update && apt-get install -y \
    # apache2
    apache2 \
    libapache2-mod-php7.1 \
    # php
    php7.1 \
    php-mysql \
    php7.1-mysql \
    php-xdebug \
    php7.1-cli \
    php7.1-common \
    php7.1-curl \
    php7.1-json \
    php7.1-mbstring \
    php7.1-xml \
    php7.1-zip \
    # nodejs
    nodejs \
    yarn \
    # crontab
    cron \
    # composer
    unzip \
    zip \
    # other
    supervisor \
    tzdata

# 設定時區
RUN echo "Asia/Taipei" > /etc/timezone && \
    rm /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 下載 composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php && \
    composer global require hirak/prestissimo

# 設定 yarn 到 $PATH 中
ENV PATH="${PATH}:`yarn global bin`"

# phpDoc 需要的額外設定
RUN ln -s /usr/share/php/data /usr/share/data

# apache2 設定
RUN a2enmod rewrite && \
    sed -i 's_DocumentRoot /var/www/html_DocumentRoot /var/www/public_' /etc/apache2/sites-available/000-default.conf && \
    sed -i '/<Directory \/var\/www\/>/,/AllowOverride/s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# 使用 supervisord 來控制服務
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# crontab 需要設定檔檔案權限為 644 才會執行
COPY crontab /etc/cron.d/laravel
RUN chmod 644 /etc/cron.d/laravel

# 刪除 apt-get 的快取
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/bin/supervisord"]
EXPOSE 80
