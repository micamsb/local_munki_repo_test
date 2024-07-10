#!/bin/zsh --no-rcs

#run on template VM
#language of template VM: en (different hostnames for different languages)

#   functions   #
function create_folder_structure (){
    SERVER_ROOT=/Users/Shared/munki_repo

    mkdir $SERVER_ROOT
    mkdir $SERVER_ROOT/catalogs
    mkdir $SERVER_ROOT/icons
    mkdir $SERVER_ROOT/manifests
    mkdir $SERVER_ROOT/pkgs
    mkdir $SERVER_ROOT/pkgsinfo

    chmod -R a+rX $SERVER_ROOT

    sudo ln -s $SERVER_ROOT /Library/WebServer/Documents/
}

function start_apachectl (){
    if [$(launchctl print system/org.apache.httpd) -ne 0]   ### Fehlermeldung beim ersten ausführen -> apache wird nicht gestartet
    then
        sudo apachectl start
    fi
}

function activate_screen_sharing (){    #activate screen sharing permission
    sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false 
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
}       ### macht noch probleme -> muss in den   System Settings >  Sharing > Screen Sharing     nochmal manuell deaktiviert und reaktiviert werden

#shared diretory damit man auf das dev Repository zugreifen kann
# mit utmctl möglich?

function changeto_munki_dev_repo (){    #braucht man nicht wenn shared directory funktioniert
    sudo defaults write \
    /Library/Preferences/ManagedInstalls.plist \
    ManifestURL \
    "https://its-cs-munki-test-01.its.unibas.ch/munki_repo_dev/manifests/ITS" \
    && \
    sudo defaults write \
    /Library/Preferences/ManagedInstalls.plist \
    SoftwareRepoURL \
    "https://its-cs-munki-test-01.its.unibas.ch/munki_repo_dev"
}

function update_repo (){
    autopkg repo-update all
    sleep 3
}

##Managed Software Center
##Munki Admin - dav.its-cs-munki-test-01.its.unibas.ch


#   script    #
create_folder_structure

start_apachectl

activate_screen_sharing

