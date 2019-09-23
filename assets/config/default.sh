# The local domain to use for development sites etc
#
# This value will be use in dns configuration ensuring all urls that use this
# domain will be pointed to 127.0.0.1. It is strongly recommended to not use
# any domains that currently exist in the world wide web, that includes .dev
#
# Notes:
#     - Do not include the leading .
LOCAL_DOMAIN="localhost"

# The root directory for the local web server
#
# This directory will serve as the default webroot for the local LEMP
# environment. The internal homebrew-lemp assets etc will also be housed
# under the directory aswell.
#
# Notes:
#     - Do not include the trailing /
WEB_ROOT_DIR="~/Sites";

# Nginx installation options
#
# Define an array of package options to use when installing nginx.
# All core nginx modules are included during installation by default, if it is
# required that some of the modules be ignored use the NGINX_OPTIONS_IGNORE
# configuration variable.
#
# A list of available external modules is avilable here:
# https://denji.github.io/homebrew-nginx/#modules
# To use an external module (not greyed out in the linked table) take its name
# from the table and wrap it like so:
#     --with-[name]-module
#         Where [name] is the name in the table
#     Example: --with-accept-language-module
#
# Notes:
#     - Ensure every item of the array is quoted.
#     - Any options defined in this array that also exist in the
#       the NGINX_OPTIONS_IGNORE config variable will be ignored.
NGINX_OPTIONS=(
    "--with-brotli-module"
    "--with-fancyindex-module"
);

# Nginx installation options to be ignored
#
# This array is very much used to remove any problematic core modulesa that are
# automatically injected on nginx installation.
#
# A list of available core modules is available here
# https://denji.github.io/homebrew-nginx/#modules
# To define a core module (greyed out in the linked table) take its name and
# wrap it like so:
#     --with-[name]
#         Where [name] is the name in the table
#     Example: --with-perl
#
# Notes:
#     - Ensure every item of the array is quoted.
NGINX_OPTIONS_IGNORE=(
    "--with-no-pool-nginx"
    "--with-perl"
);
