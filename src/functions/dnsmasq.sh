#!/usr/bin/env bash

# Adds a dnsmasq record
#
# Usage: dnsmasq_add <domain> [ip]
# If an ip address is not given, 127.0.0.1 will be used
function dnsmasq_add() {
    DOMAIN=$(echo $1 | sed "s|^\.*||g")
    if [ -z $DOMAIN ]; then
        error "No domain provided"
        exit 1;
    fi

    IP=$2
    if [ -z $IP ]; then
        IP="127.0.0.1"
    fi

    # Remove any previous records for this domain
    dnsmasq_delete $DOMAIN

    echo "address=/.$DOMAIN/$IP" >> "/usr/local/etc/dnsmasq.conf"

    # Create the dns resolvers to use with dnsmasq
    sudo mkdir -p /etc/resolver
    sudo tee /etc/resolver/$DOMAIN > /dev/null <<EOF
nameserver 127.0.0.1
EOF
}

# Removes a dnsmasq record
#
# Usage: dnsmasq_remove <domain>
function dnsmasq_delete() {
    DOMAIN=$(echo $1 | sed "s|^\.*||g")
    if [ -z $DOMAIN ]; then
        error "No domain provided"
        exit 1;
    fi

    if [[ -f "/usr/local/etc/dnsmasq.conf" ]]; then
        mv /usr/local/etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf.dnsmasq_remove
        sed -e "/.$DOMAIN/d" \
        -e "/^[[:space:]]*$/d" \
        /usr/local/etc/dnsmasq.conf.dnsmasq_remove > /usr/local/etc/dnsmasq.conf
        rm -f /usr/local/etc/dnsmasq.conf.dnsmasq_remove
    fi

    # Remove the resolver
    sudo rm -f /etc/resolver/$DOMAIN
}

# Reloads dnsmasq service and the dns cache
#
# Usage: dnsmasq_reload
function dnsmasq_reload() {
    sudo brew services stop dnsmasq
    sudo dscacheutil -flushcache
    sudo brew services start dnsmasq
}
