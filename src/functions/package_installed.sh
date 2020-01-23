#!/usr/bin/env bash

# Checks a package installed
function package_installed () {
    brew list $1 &> /dev/null
    return $?
}
