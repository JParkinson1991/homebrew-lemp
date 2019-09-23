#!/usr/bin/env bash
# Requires lots of functionality to be included to run stand alone.
# Strongly recommended to run via the homebrew-lemp

# Stop and unlink all managed packages/services
stop_all
unlink_all

# Tap the rmtree package as needed
if ! brew list rmtree; then
    HAS_RMTREE=1
    brew tap beeftornado/rmtree
else
    HAS_RMTREE=0
fi

# Delete the homebrew-lemp folder
rm -rf $WEB_ROOT_DIR/.homebrew-lemp

# Delete nginx full and dependencies
brew rmtree nginx-full
brew untap denji/nginx
brew cask uninstall xquartz

# Delete dnsmasq and custom files
brew rmtree dnsmasq
sudo rm -f /etc/resolver/localhost
sudo rm -rf /usr/local/Cellar/dnsmasqyy

# Delete homebrew-deprecate php versions
brew rmtree php@5.6
brew rmtree php@7.0
brew untap exolnet/homebrew-deprecated

# Delete core php versions
brew rmtree php@7.1
brew rmtree php@7.2
brew rmtree php

# Delete mysql
brew rmtree mysql@5.7
sudo rm /usr/local/mysql
sudo rm -rf /usr/local/var/mysql
sudo rm -rf /usr/local/mysql*
sudo rm ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
sudo rm -rf /Library/StartupItems/MySQLCOM
sudo rm -rf /Library/PreferencePanes/My*
launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
rm -rf ~/Library/PreferencePanes/My*
sudo rm -rf /Library/Receipts/mysql*
sudo rm -rf /Library/Receipts/MySQL*
sudo rm -rf /private/var/db/receipts/*mysql*

# Delete phpmyadmin
brew rmtree phpmyadmin

# Remove rm tree if not previously installed
if [[ $HAS_RMTREE -ne 0 ]]; then
    brew untap beeftornado/rmtree
fi

brew cleanup
brew services cleanup
sudo brew services cleanup

# Catch alls
notice "Deleting homebrew.mxcl.nginx-full.plist"
rm -f "$HOME/Library/LaunchAgents/homebrew.mxcl.nginx-full.plist";

notice "Please review outputs above checking any errors/warnings"
success "Purge complete"

exit 0;
