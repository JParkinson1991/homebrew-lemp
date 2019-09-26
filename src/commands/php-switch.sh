#!/usr/bin/env bash
# Requires lots of functionality to be included to run stand alone.
# Strongly recommended to run via the homebrew-lemp

# Defines the allowed php values
# Format [MAJOR][MINOR]
PHP_VERSIONS=(56 70 71 72 73)

# Ensure a php version passed
if [[ $# -eq 0 ]]; then
    error "No PHP version provided"
    notice "Supported Versions: ${PHP_VERSIONS[*]}"
    exit 1;
fi

# Check a valid php version was given
if ! array_contains $1 "${PHP_VERSIONS[@]}"; then
    error "Invalid PHP version provided"
    notice "Supported Versions: ${PHP_VERSIONS[*]}"
    exit 1
fi

# Wrap stop commands into function for simplicity
notice "Stopping PHP ..."
stop_php &> /dev/null
unlink_php &> /dev/null

notice "Starting PHP $1 ..."
if [[ $1 == "56" ]]; then
    brew services start php@5.6 &> /dev/null
    brew link --force --overwrite php@5.6 &> /dev/null
elif [[ $1 == "70" ]]; then
    brew services start php@7.0 &> /dev/null
    brew link --force --overwrite php@7.0 &> /dev/null
elif [[ $1 == "71" ]]; then
    brew services start php@7.1 &> /dev/null
    brew link --force --overwrite php@7.1 &> /dev/null
elif [[ $1 == "72" ]]; then
    brew services start php@7.2 &> /dev/null
    brew link --force --overwrite php@7.2 &> /dev/null
elif [[ $1 == '73' ]]; then
    brew services start php &> /dev/null
    brew link --force --overwrite php &> /dev/null
fi

# If nginx is running, reload it
if [ -x "$(command -v nginx)" ]; then
    notice "Restarting NGINX ..."
    sudo nginx -s reload
fi

BASH_SOURCE_FILES=(".bash_profile" ".bashrc")
for file in "${BASH_SOURCE_FILES[@]}"; do
    if [[ -f "$HOME/$file" ]]; then
        # shellcheck disable=SC1090
        /bin/bash -c "source $HOME/$file"
    fi
done

# Source zsh files using
if [[ -f "$HOME/.zshrc" ]]; then
    /bin/zsh -c "source $HOME/.zshrc"
fi

notice "Showing PHP Version ..."
php -v

exit 0


