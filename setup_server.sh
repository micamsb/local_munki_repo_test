#!/bin/zsh --no-rcs

#creates a folder structure; connects to the dev repo; clones a VM from template and starts it


#   Set up template   #
#New UTM VM with name according to variable
#Press command k in finder window and connect to: dav.its-cs-munki-test-01.its.unibas.ch/files/
#Press "New Shared Directory" in UTM and choose: dav.its-cs-munki-test-01.its.unibas.ch/files/html/munki_repo_dev
#Start VM
    #Set language according to variable
    #Set username and password according to variable
    #Activate screen sharing permission at: System Settings > General > Sharing > Screen Sharing
    #Open search machine and enroll JAMF with following link: https://its-mcs-dm.its.unibas.ch:8443/enroll/
        #Wait until completion & follow instructions if needed (also review the MDM Profile in System Settings > Profiles)
#Restart VM and follow instructions if needed
#Copy the serial number (to create a Manifest in MunkiAdmin)

#You should be able to run this script (as long as UTM is installed).


#   variables   #
name="test"
user="test"
password="test"
language="en"                                   #different hostname pattern for different languages!    #Options: en / de
clone_suffix="clone"
suffix=$clone_suffix
hostname="${name}s-Virtual-Machine.local"
ip_address="192.168.64.12"

###
#if [ $language=="en" ]
#then    
#    hostname="${name}s-Virtual-Machine.local"
#fi
#
#if [ $language=="de" ]
#then
#    hostname="Virtuelle-Maschine-von-${name}.local"
#fi
###

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
    launchctl print system/org.apache.httpd 

    if [ $? -eq 0 ]
    then
        sleep .2
    else 
        sudo apachectl start
    fi
}

function changeto_munki_dev_repo (){ 
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
    sleep .5
}

function adjust_autopkg (){
    /usr/local/bin/autopkg run --key MUNKI_REPO=“/Volumes/MUNKI_PROD“      #?
}

function activate_utmctl (){ 
    #/Applications/UTM.app/Contents/MacOS/utmctl
    sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl
}

function open_utm(){
    if ps -A | grep -v grep | grep -iq 'utm.app'
    then 
        sleep .2
    else 
        open /Applications/UTM.app/
        sleep .5
    fi
}

function stop_templateVM (){
    if [[ $(utmctl status $name)=="started" ]]
    then
        utmctl stop $name
        sleep .2
    fi
}

function delete_VMcopy (){
    if [[ $(utmctl status ${name}_${suffix})=="started" ]]
    then    
        utmctl stop ${name}_${suffix}
        sleep .5
    fi

    utmctl delete ${name}_${suffix}
}

function check_delete_existing_VMcopy (){  
    while ( utmctl list | grep ${name}_${suffix} )
    do
        if [ $? -eq 0 ]
        then
            delete_VMcopy
        fi
    done
}

function clone_templateVM (){
    utmctl clone $name --name ${name}_${suffix} 
    sleep .2
}

function launch_VMcopy (){
   utmctl start ${name}_${suffix}
    sleep .25
}

function share_screen (){
    open vnc://${user}:${password}@$hostname       # vnc://[user]:[password]@[server]:[port]     #port not required? (port=5900 ?)
}       ### Man muss sich dann noch in der VM einloggen


#   script    #
#create_folder_structure        #funktioniert

#start_apachectl        #funktioniert aber grosser output

#changeto_munki_dev_repo        #funktioniert

#update_repo        #funktioniert

#adjust_autopkg     #manuell?

#activate_utmctl        #funktioniert

open_utm        #funktioniert

stop_templateVM     #funktioniert

#delete_VMcopy      #funktioniert in check_delete_existing_VMcopy

check_delete_existing_VMcopy        #funktioniert

clone_templateVM        #funktioniert

launch_VMcopy       #funktioniert

share_screen        #funktionierte -> bug wenn JAMF enrollt ist


echo "$hostname"
echo "$name"
echo "$user"
echo "$ip_address"
echo "Script completed."