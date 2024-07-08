#!/bin/zsh --no-rcs

#run on template VM
#language of template VM: en (different hostnames for different languages)

# Create folder structure
SERVER_ROOT=/Users/Shared/munki_repo

mkdir $SERVER_ROOT
mkdir $SERVER_ROOT/catalogs
mkdir $SERVER_ROOT/icons
mkdir $SERVER_ROOT/manifests
mkdir $SERVER_ROOT/pkgs
mkdir $SERVER_ROOT/pkgsinfo

chmod -R a+rX $SERVER_ROOT

sudo ln -s $SERVER_ROOT /Library/WebServer/Documents/

#start apachectl server if not running already
launchctl print system/org.apache.httpd
if [$? -eq 1]
then
    sudo apachectl start
fi

#activate screen sharing permission
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false 
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
### macht noch probleme -> muss in den   System Settings >  Sharing > Screen Sharing     nochmal deaktiviert und reaktiviert werden (oder es braucht einfach ziemlich lange?)

#hostname for screensharing
echo "$(hostname)"
### funktioniert immer nach dem selben pattern -> nicht notwendig?

### Man kann auch schon beim Template die wichtigen Apps / Tabs öffnen und die werden dann auch bei der duplizierten VM direkt geöffnet