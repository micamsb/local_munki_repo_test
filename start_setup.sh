#!/bin/zsh --no-rcs

# Script creates folder structure and activates utmctl
# Runs once

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

function activate_utmctl (){ 
    #/Applications/UTM.app/Contents/MacOS/utmctl
    sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl
}


#   script   #
create_folder_structure 2> /dev/null
activate_utmctl


#   testing   #
echo "Script setup_structure complete."