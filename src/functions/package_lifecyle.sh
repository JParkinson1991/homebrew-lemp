#!/usr/bin/env bash

# Starts the stack in it's default state
function start_default(){
    stop_all &> /dev/null
    unlink_all &> /dev/null

    brew link --force --overwrite nginx-full
    brew link --force --overwrite php
    brew link --force --overwrite dnsmasq
    brew link --force --overwrite mysql@5.7

    brew services start nginx-full
    sudo brew services start dnsmasq
    brew services start php
    brew services start mysql@5.7

    /usr/local/opt/mysql@5.7/bin/mysql.server start
}

# Stop all php services
function stop_php(){
    brew services stop php@5.6
    brew services stop php@7.0
    brew services stop php@7.1
    brew services stop php@7.2
    brew services stop php@7.3
    brew services stop php #7.4
}

# Blindly stops all of the services managed by homebrew lemp
function stop_all(){
    /usr/local/opt/mysql@5.7/bin/mysql.server stop
    nginx -s stop

    brew services stop denji/nginx/nginx-full
    sudo brew services stop dnsmasq
    stop_php
    brew services stop mysql@5.7

    killall -9 mysql
    killall -9 mysqld
    killall -9 mysqld_safe
}

# Unlink all php packages
function unlink_php(){
    brew unlink php@5.6
    brew unlink php@7.0
    brew unlink php@7.1
    brew unlink php@7.2
    brew unlink php@7.3
    brew unlink php #7.3
}

# Blindly unlinks all of the packages managed by homebrew lemp
function unlink_all(){
    brew unlink nginx-full
    brew unlink dnsmasq
    unlink_php
    brew unlink mysql@5.7
}
