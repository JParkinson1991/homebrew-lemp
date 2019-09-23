#!/usr/bin/env bash

# Determines if a string contains a given sub string
#
# Usage: string_contains <haystack> <needle>
function string_contains() {
    if [[ $1 == *"${2}"* ]]; then
        return 0 #true
    else
        return 1 #false
    fi
}

# Determines if a string ends with a given sub string
#
# Usage: string_ending <haystack> <needle>
function string_ending() {
    if [[ $1 == *"$2" ]]; then
        return 0 #true
    else
        return 1 #false
    fi
}

# Determines if a string ends with a given sub string
#
# Usage: string_starting <haystack> <needle>
function string_starting() {
    if [[ $1 == "$2"* ]]; then
        return 0
    else
        return 1
    fi
 }
