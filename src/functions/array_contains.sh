#!/usr/bin/env bash

# Checks if a value is within an array
#
# Usage: array_contains $search "{$array[@]}"
function array_contains () {
    local seeking=$1; shift
    local in=1
    for element; do
        if [[ $element == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}
