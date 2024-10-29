#!/bin/zsh --no-rcs

#   Set up template   #
#New UTM VM with name according to variable
#Press command k in finder window and connect to: dav.its-cs-munki-test-01.its.unibas.ch/files/
#Press "New Shared Directory" in UTM and choose: dav.its-cs-munki-test-01.its.unibas.ch/files/html/munki_repo_dev
#Start VM
    #Set language according to variable
    #Set username and password according to variable
    #Activate screen sharing permission at: System Settings > General > Sharing > Screen Sharing
    #Maually enroll Munki (bug with screen sharing when enrolled with jamf)
#Copy the serial number (to create a Manifest in MunkiAdmin)

#You should be able to run this script as long as UTM is installed.


#   variables   #
NAME="template"
USER=$NAME
PASSWORD=$NAME
LANGUAGE="en"                                                       #different hostname pattern for different languages!
CLONE_SUFFIX="clone"
    SUFFIX=$CLONE_SUFFIX
HOSTNAME="${NAME}s-Virtual-Machine.local"                           #for ${LANGUAGE}=="en"


#   functions   #
function start_apachectl (){
    launchctl print system/org.apache.httpd &> /dev/null

    if [ $? -eq 0 ]; then
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

function change_munki_repo_preferences (){
        launchctl print system/org.apache.httpd &> /dev/null

    if [ $? -eq 0 ]; then                                                       #checks if server is running
        /usr/local/bin/autopkg run --key MUNKI_REPO=$SERVER_ROOT &> /dev/null   #?
        #defaults write com.github.autopkg MUNKI_REPO /Volumes/files/html/munki_repo_dev
    fi
}

function update_repo (){
    autopkg repo-update all
    sleep .5
}

function open_utm(){
    if ps -A | grep -v grep | grep -iq 'utm.app'; then              #check if utm is on
        sleep .2
    else 
        open /Applications/UTM.app/
        sleep .5
    fi
}

function stop_templateVM (){
    if [[ $(utmctl status $NAME)=="started" ]]; then                #checks if template is running
        utmctl stop $NAME
        sleep .2
    fi
}

function delete_VMcopy (){
    if [[ $(utmctl status ${NAME}_${SUFFIX})=="started" ]]; then    #checks if copy is running  
        utmctl stop ${NAME}_${SUFFIX}
        sleep .5
    fi

    utmctl delete ${NAME}_${SUFFIX}
}

function check_delete_existing_VMcopy (){  
    while ( utmctl list | grep ${NAME}_${SUFFIX} ); do              #checks if copy already exists
        if [ $? -eq 0 ]; then
            delete_VMcopy
        fi
    done
}

function clone_templateVM (){
    utmctl clone $NAME --name ${NAME}_${SUFFIX} 
    sleep .2
}

function launch_VMcopy (){
    utmctl start ${NAME}_${SUFFIX}
    sleep .25
}

function share_screen (){
    open vnc://${USER}:${PASSWORD}@$HOSTNAME                        # vnc://[user]:[password]@[server]:[port]
}

function revert_munki_repo_preferences (){
    defaults write com.github.autopkg MUNKI_REPO /volumes/files/html/munki_repo_dev &> /dev/null
}


#   script   #
start_apachectl                                   
changeto_munki_dev_repo
change_munki_repo_preferences 
update_repo > /dev/null
open_utm
stop_templateVM &> /dev/null
###delete_VMcopy &> /dev/null                                                  #läuft in check_delete_existing_VMcopy
check_delete_existing_VMcopy &> /dev/null
clone_templateVM 
launch_VMcopy
share_screen                                                                    # -> bug wenn JAMF enrollt ist -> manuelles munki enrollment


#   testing   #
#echo "Hostname: $HOSTNAME"
#echo "Name: $NAME"
#echo "Username: $USER"
#echo "Password: $PASSWORD"
echo "Script setup_server completed."