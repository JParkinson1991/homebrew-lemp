#!/usr/bin/env bash
# Requires inclusion of the formatting utility file, auto included when executed via homebrew-lemp.sh entrypoint.

# Outputs a standardised error message
function error() {
    echo -e "${RED}Error:${RESET} $1"
}

# Outputs a standardised success message
function success() {
    echo -e "${GREEN}Success:${RESET} $1"
}

# Outputs a standardises notice message
function notice() {
    echo -e "${BLUE}Notice:${RESET} $1"
}
