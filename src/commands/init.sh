#!/usr/bin/env bash
# Requires lots of functionality to be included to run stand alone.
# Strongly recommended to run via the homebrew-lemp

# # # # # # # # # # #
# CONFIGURATION INIT
# # #

load_config
notice "Loaded configuration"
echo "> LOCAL_DOMAIN: $LOCAL_DOMAIN"
echo "> WEB_ROOT_DIR: $WEB_ROOT_DIR"
echo "> NGINX_OPTIONS: ${NGINX_OPTIONS_RAW[*]}"
echo "> NGINX_OPTIONS_IGNORE: ${NGINX_OPTIONS_IGNORE[*]}"
echo "> NGINX_OPTIONS (Computed): ${NGINX_OPTIONS[*]}"
echo "Note: nginx core modules (excluding ignored) will be automatically included"
while true; do
    read -n 1 -p "Continue with the above configuration? [y/N] " yn
    case $yn in
        [Yy]* ) echo ""; break;;
        [Nn]* ) exit;;
        * ) exit;;
    esac
done

# Export the config values that may exist in tokenized config giles
# Example, envsubst used in nginx conf files
export LOCAL_DOMAIN=$LOCAL_DOMAIN
export WEB_ROOT_DIR=$WEB_ROOT_DIR

# Initialise local script variables not loaded via configuration files.
HBL_DIR=$WEB_ROOT_DIR/.homebrew-lemp;
NGINX_DYNAMIC_CONFIG=()

# # # # # # # # # # #
# PRE-INSTALLATION PREPARATIONS
# # #

# Create the web root directory if needed,
if ! [[ -d $WEB_ROOT_DIR ]]; then
    notice "Creating project root at: $WEB_ROOT_DIR ..."
    mkdir -p "$WEB_ROOT_DIR"
fi

# Prepare homebrew lemp asset directory
# Can be deleted as on initialisations as it's managed only by this package
rm -rf $HBL_DIR
mkdir -p $HBL_DIR

# Ensure homebrew exists, if not, installed it.
if ! [ -x "$(command -v brew)" ]; then
    notice "Installing homebrew ..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        error "Failed to install homebrew"
        exit 0
    fi
fi

# Ensure correct access
sudo chown -R "$(whoami)" "$(brew --prefix)"/*

# Update homebrew prior to continuing
notice "Updating Homebrew ..."
brew update

# Ensure git exists, if it doesn't, install
if ! [ -x "$(command -v git)" ]; then
    notice "Installing git ..."
    brew install git
fi

# Ensure the envsubst command can be used
if [ ! -x "$(command -v envsubst)" ]; then
    brew link --force gettext
fi

# # # # # # # # # # #
# HOMEBREW-LEMP INSTALLATION
# # #

# Tap the nginx repositories
notice "Tapping denji/nginx ..."
brew tap denji/nginx

# Output state message
notice "Installing nginx-full ..."

# Determine the nginx options that should be used when installing the nginx-full package
echo "> Determining options ..."
while read -r line; do
    if [[ $line == --with-* ]] && [[ $line != --with-*-module ]]; then
        # shellcheck disable=SC2199
        if ! array_contains $line "${NGINX_OPTIONS[@]}" && ! array_contains $line "${NGINX_OPTIONS_IGNORE[@]}"; then
            NGINX_OPTIONS+=("$line")
        fi
    fi
done < <(brew options nginx-full)

# Output state message
echo "> Checking external dependencies"

# If imlib2 is to be included with the nginx install ensure it's external dependency on
# xquartz is met.
# shellcheck disable=SC2199
if array_contains "--with-imlib2" "${NGINX_OPTIONS[@]}"; then
    brew cask list xquartz || brew cask install xquartz --verbose;
fi

# If the nginx brotli module is to be install ensure the brotli dependencies are met
# shellcheck disable=SC2199
if array_contains "--with-brotli-module" "${NGINX_OPTIONS[@]}"; then
    echo "> Installing brotli"

    # Install brotli module first rather than dynamically if requested
    # This is required so the dependency on the brotli package can be fulfilled prior
    # to any dependency checks/configuration etc done during the nginx-full install
    brew install brotli-nginx-module
    rm -rf /usr/local/share/brotli-nginx-module/deps/brotli
    git clone https://github.com/google/brotli.git /usr/local/share/brotli-nginx-module/deps/brotli

    # Add the brotli file to dynamic configuration
    NGINX_DYNAMIC_CONFIG+=('brotli.dynamic.conf')
fi

# If fancy index is to be used, install the theme
if array_contains "--with-fancyindex-module" "${NGINX_OPTIONS[@]}"; then
    echo "> Installing nginx index theme"

    # Clone the theme into the hbl lemp web dir
    git clone https://github.com/TheInsomniac/Nginx-Fancyindex-Theme.git $HBL_DIR/fancyindex;

    # Create a copy of the original config before altering paths to the homebrew lemp dir
    cp $HBL_DIR/fancyindex/fancyindex.conf $HBL_DIR/fancyindex/fancyindex.conf.orig
    sed -e 's|/fancyindex/|/.homebrew-lemp/fancyindex/|g' \
        -e 's|fancyindex_ignore "fancyindex"|fancyindex_ignore ".homebrew-lemp"|g' \
        -e '/^#[^!].*/d' \
        -e 's/\(.*[^!]\)#.*[^}]/\1/' \
        -e "s/^[ \t]*//" \
        -e "s/[ \t]*$//" $HBL_DIR/fancyindex/fancyindex.conf.orig > $HBL_DIR/fancyindex/fancyindex.conf

    # Create a copy of the header file before altering paths to the homebrew lemp dir
    cp $HBL_DIR/fancyindex/header.html $HBL_DIR/fancyindex/header.html.orig
    sed -e 's|/fancyindex/css/fancyindex.css|/.homebrew-lemp/fancyindex/css/fancyindex.css|g' \
        $HBL_DIR/fancyindex/header.html.orig > $HBL_DIR/fancyindex/header.html

    # Create a copy of the footer file before altering paths to the homebrew lemp dir
    # Also remove the closing body and html tags
    cp $HBL_DIR/fancyindex/footer.html $HBL_DIR/fancyindex/footer.html.orig
    sed -e 's|/fancyindex/js/history.js|/.hombrew-lemp/fancyindex/js/history.js|g' \
        -e '/<\/body>/d' \
        -e '/<\/html>/d' \
        $HBL_DIR/fancyindex/footer.html.orig > $HBL_DIR/fancyindex/footer.html

    # Append a new script to show first rows of tables on index page
    # Close the previously removed body html tags
    cat <<EOT >> "$HBL_DIR/fancyindex/footer.html"
<script>
  if (currentPath == '/') {
    document.querySelector('.box-content tbody tr').style.display = "table-row"
  }
</script>
</body>
</html>
EOT

    # Add the fancyindex file to dynamic configuration
    NGINX_DYNAMIC_CONFIG+=('fancyindex.dynamic.conf')
fi

# Install nginx full, with its external dependencies met and the required options
brew install nginx-full ${NGINX_OPTIONS[*]};

# Output state message
echo "> Configuring ..."

# Configure nginx to be run on port 80 without the need to sudo
sudo chown root:wheel /usr/local/opt/nginx-full/bin/nginx
sudo chmod u+s /usr/local/opt/nginx-full/bin/nginx

# Make a copy of the original installed nginx, and move the one provided by this module
# into it's place. Create all of the directories this new file references to avoid any
# errors on start.
mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.orig
cp $APP_ROOT/assets/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf
sudo mkdir -p /var/log/nginx
mkdir -p /usr/local/etc/nginx/modules
mkdir -p /usr/local/etc/nginx/servers

# Process all of the nginx configuration assets provided by this package
# Each configuration file is processed, environment variables are substituted for actual
# values and moved into the nginx installation directory
for file in $APP_ROOT/assets/nginx/*/*.conf; do
    # Handle dynamic config files
    # If a file is dynamic it will be skipped unless added to the NGINX_DYNAMIC_CONFIG array
    # Files that are to be added will have the '.dynamic' part of the filename removed
    if [[ $file == *.dynamic.conf ]]; then
        if array_contains $(basename $file) "${NGINX_DYNAMIC_CONFIG[@]}"; then
            file="${file/.dynamic/}"
        else
            continue
        fi
    fi

    # shellcheck source=/dev/null
    if [[ ! -d "/usr/local/etc/nginx/$(basename "$(dirname "$file")")" ]]; then
        mkdir -p "/usr/local/etc/nginx/$(basename "$(dirname "$file")")"
    fi
    envsubst '${HOME},${LOCAL_DOMAIN},${WEB_ROOT_DIR}' < "$file" \
        > "/usr/local/etc/nginx/$(basename "$(dirname "$file")")/$(basename $file)"
done;

# Install dnsmasq
notice "Installing dnsmasq ..."
brew install dnsmasq

# Configure dnsmasq, take a copy of the original file if it does not already exist
# Remove the default config file and replace via echo
if [[ ! -f  "/usr/local/etc/dnsmasq.conf.orig" ]]; then
    cp "/usr/local/etc/dnsmasq.conf" "/usr/local/etc/dnsmasq.conf.orig"
fi
rm -f "/usr/local/etc/dnsmasq.conf"
cp "/usr/local/etc/dnsmasq.conf.orig" "/usr/local/etc/dnsmasq.conf"
echo "address=/.$LOCAL_DOMAIN/127.0.0.1" >> "/usr/local/etc/dnsmasq.conf"

# Create the dns resolvers to use with dnsmasq
sudo mkdir -p /etc/resolver
sudo rm -f /etc/resolver/$LOCAL_DOMAIN
sudo tee /etc/resolver/$LOCAL_DOMAIN > /dev/null <<EOF
nameserver 127.0.0.1
domain $LOCAL_DOMAIN
EOF

# Flush the dns cache so it dnsmasq changes are updated
sudo dscacheutil -flushcache

# For mojave users ensure sdk headers are installed
if [[ -f /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg ]]; then
    sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
fi

# Install php versions
brew tap exolnet/homebrew-deprecated
brew install php@5.6
brew unlink php@5.6
brew install php@7.0
brew unlink php@7.0
brew install php@7.1
brew unlink php@7.1
brew install php@7.2
brew unlink php@7.2
brew install php

# Install the info site
mkdir -p "$HBL_DIR/phpinfo"
cp "$APP_ROOT/assets/php/info.php" "$HBL_DIR/phpinfo/info.php"

# Install mysql
brew install mysql@5.7
sudo rm -f "/usr/local/etc/my.cnf"
cp "$APP_ROOT/assets/mysql/my.cnf" "/usr/local/etc/my.cnf"
/usr/local/opt/mysql@5.7/bin/mysql.server start
/usr/local/opt/mysql@5.7/bin/mysql_secure_installation

# Install phpmyadmin
brew install phpmyadmin
cp /usr/local/etc/phpmyadmin.config.inc.php /usr/local/etc/phpmyadmin.config.inc.php.orig
blowfish_secret=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
sed -e "s|\$cfg\['blowfish_secret'\] = ''|\$cfg\['blowfish_secret'\] = '$blowfish_secret'|g" \
    /usr/local/etc/phpmyadmin.config.inc.php.orig > /usr/local/etc/phpmyadmin.config.inc.php

# # # # # # # # # # #
# POST INSTALLATION OUTPUTS
# # #

# Starts the stack
notice "Starting the Stack"
start_default

success "Homebrew lemp initialised"
notice "Web root available at: http://localhost"
notice "PHP Info available at: http://info.$LOCAL_DOMAIN"
notice "DB Admin available at: http://phpmyadmin.$LOCAL_DOMAIN"

exit 0;
