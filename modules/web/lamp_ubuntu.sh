#!/bin/bash

# shellcheck disable=SC2232
sudo export DEBIAN_FRONTEND=noninteractive

# Initialize the PHP Package Repository
sudo apt-get update && apt-get install -y language-pack-en-base && \
     export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && \
     sudo apt-get install -y software-properties-common && \
     sudo add-apt-repository -y ppa:ondrej/php && \
     sudo apt-get update

# Install Nginx, PHP
sudo apt-get -y install apache2 php8.2 libapache2-mod-php8.2 php8.2-common \
       php8.2-cli php8.2-curl php8.2-mbstring \
       php8.2-mysql php8.2-pgsql php8.2-gd php8.2-bcmath php8.2-readline \
       php8.2-zip php8.2-imap php8.2-xml php8.2-intl php8.2-soap \
       php8.2-memcached php8.2-xdebug php8.2-redis php8.2-sqlite3

# Install Composer (PHP Package Dependency Manager)
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && sudo php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && sudo php composer-setup.php --install-dir=/usr/bin --filename=composer \
  && sudo php -r "unlink('composer-setup.php');"

sudo a2enmod rewrite ssl

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1 apt-get -y upgrade

sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1 apt-get -y dist-upgrade