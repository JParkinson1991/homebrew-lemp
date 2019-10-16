#!/usr/bin/env bash

dnsmasq_delete "$1"
dnsmasq_reload
exit 0;
