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
launchctl print system/org.apache.httpd         ### Fehlermeldung beim ersten ausführen -> apache wird nicht gestartet
if [$? -ne 0]
then
    sudo apachectl start
fi

#activate screen sharing permission
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false 
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
### macht noch probleme -> muss in den   System Settings >  Sharing > Screen Sharing     nochmal manuell deaktiviert und reaktiviert werden

###activate remote login permission
###sudo systemsetup -setremotelogin on

#shared diretory damit man auf das dev Repository zugreifen kann
# mit utmctl möglich?

####
##swiches to the Munki Dev Repository
#sudo defaults write \
#    /Library/Preferences/ManagedInstalls.plist \
#    ManifestURL \
#    "https://its-cs-munki-test-01.its.unibas.ch/munki_repo_dev/manifests/ITS" \
#    && \
#sudo defaults write \
#    /Library/Preferences/ManagedInstalls.plist \
#    SoftwareRepoURL \
#    "https://its-cs-munki-test-01.its.unibas.ch/munki_repo_dev"

#autopkg repo-update all

##Managed Software Center
##Munki Admin - dav.its-cs-munki-test-01.its.unibas.ch