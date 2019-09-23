#!/usr/bin/env bash
# Requires the configuration of the $APP_ROOT variable.
# Already configured if this file is accessed via the homebrew-lemp entry point
# Requires the inclusion of the array_contains function.
# Already included if the file is accessed via the homebrew-lemp entry point

# Loads the configuration varaibles and applies any overrides that exist in
# the in ~/.homebrewlemp config file if it exists
function load_config() {
    # shellcheck disable=SC1090
    source "$APP_ROOT/assets/config/default.sh"

    # Load overrides if exist
    if [[ -f "$HOME/.homebrewlemp" ]]; then
        # shellcheck disable=SC1090
        source "$HOME/.homebrewlemp";
    fi

    # Remove any leading dots from local domain
    LOCAL_DOMAIN=$(echo ${LOCAL_DOMAIN} | sed "s|^\.*||g")

    # Remove any trailing slashes from web root dir
    # Swap out the use of ~ for the $HOME variable so path is absolute.
    WEB_ROOT_DIR=$(echo ${WEB_ROOT_DIR} | sed -e "s|~|$HOME|g" -e "s|/*$||g")

    # Store the raw options as set during config for use outside of this
    # function.
    NGINX_OPTIONS_RAW="${NGINX_OPTIONS[@]}"

    # Remove all ignored nginx options that exist in the options array
    for ignoredOption in "${NGINX_OPTIONS_IGNORE[@]}"; do
        if array_contains "$ignoredOption" "${NGINX_OPTIONS[@]}"; then
            NGINX_OPTIONS=("${NGINX_OPTIONS[@]/$ignoredOption}")
        fi
    done;
}
