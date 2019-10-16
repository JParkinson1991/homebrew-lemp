#!/usr/bin/env bash

dnsmasq_add "$1" "$2"
dnsmasq_reload
exit 0;
