#!/usr/bin/env bash
# Requires the status messages functionality and app environment variables to be run standalone.
# Strongly recommended to run via the homebrew-lemp

# Determine if overwriting original config
overwrite=0;
while getopts 'f' opt; do
    case $opt in
        f) overwrite=1 ;;
    esac
done
shift "$(( OPTIND - 1 ))"

# Load overrides if exist
if [[ -f "$HOME/.homebrewlemp" ]]; then
    if [[ $overwrite -eq 0 ]]; then
        error "$HOME/.homebrewlemp already exists, overwrite with -f flag"
        exit 1;
    else
        notice "Overwriting previous configuration file"
    fi
fi

rm -f "$HOME/.homebrewlemp"
cp "$APP_ROOT/assets/config/default.sh" "$HOME/.homebrewlemp"

success "Created $HOME/.homebrewlemp"
exit 0
