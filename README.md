# Homebrew LEMP

An opinionated LEMP stack installation for Mac OS using the homebrew package manager.

This commands provided by this package should be used to initially deploy a LEMP development stack.
It is not intended to handle the day to day upkeep of the stack or to provide ways of updating configuration's etc etc.
It is much more of a local environment bootstrapper.

What this package will install/configure/setup:
- Web document root at a configured location
- Packages:
    - nginx
        - All core modules/options included
        - External modules
            - brotli
            - fancyindex
        - Configurable
    - dnsmasq
        - Pointing all local domains to 127.0.0.1
            - no more editing /etc/hosts
            - local domain configuration
    - php
        - Versions: `5.6, 7.0, 7.1, 7.2, 7.3`
    - mysql
        - Version: `5.7`
    - phpmyadmin

## Requirements

A Mac.

## Installing

The terminal code examples below are denoted by:
- `#` Comment, no need to run
- `$` Command prompt, should be executed
- `>` Command output, read

Replace `INSTALL_PATH` with your chosen download/install/source path.

```
# Clone or download this repository to a local path on your mac.

# Example git clone method 
$ git clone <todo url> INSTALL_PATH
```

```
# Link bash scripts to a directory under $PATH

# View path directories 
$ echo $PATH
  > /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Enter install directory, link scripts, make executable
$ cd LOCAL_PATH
$ ln -s $PWD/bin/homebrew-lemp.sh /usr/local/bin/homebrew-lemp
$ chmod +x /usr/local/bin/homebrew-lemp
```

## Configuration

Default configuration exists in the file `./assets/config/default.sh`

Values in this configuration file can be overwritten creating a configuration file at `~/.homebrewlemp`

To view detailed information on the configuration available view the default configuration file in this repository.

## Usage

```
# Initialise the homebrew lemp stack
$ homebrew-lemp init

# Start the stack in it's default state
$ homebrew-lemp start

# Switch php version of the stack
# Allowed versions: 56 70 71 72 73
$ homebrew-lemp php-switch <version>

# Stop the stack
$ homebrew-lemp stop

# Delete the stack
$ homebrew-lemp purge 

# View cli help
$ homebrew-lemp help
$ homebrew-lemp [command] -h

```
