#!/bin/zsh --no-rcs

# To use this script a UTM VM has to be sat up as a template.


#   variables   #
NAME="template"
USER=$NAME
PASSWORD=$NAME
LANGUAGE="en"                                                                   # different hostname pattern for different languages!
CLONE_SUFFIX="clone"
    SUFFIX=$CLONE_SUFFIX
HOSTNAME="${NAME}s-Virtual-Machine.local"                                       # for ${LANGUAGE}=="en"
SERVER_ROOT=/Users/Shared/munki_repo


#   functions   #
function start_apachectl (){                                                    # starts apachectl server
    launchctl print system/org.apache.httpd &> /dev/null

    if [ $? -eq 0 ]; then
        sleep .2
    else 
        sudo apachectl start
    fi
}

function changeto_munki_dev_repo (){                                            # switches to development repository
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

    if [ $? -eq 0 ]; then                                                       # checks if server is running
        #/usr/local/bin/autopkg run --key MUNKI_REPO=$SERVER_ROOT &> /dev/null
        defaults write com.github.autopkg MUNKI_REPO $SERVER_ROOT
    fi
}

function update_repo (){                                                        # updates repositories
    autopkg repo-update all
    sleep .5
}

function open_utm(){
    if ps -A | grep -v grep | grep -iq 'utm.app'; then                          # check if utm is on
        sleep .2
    else 
        open /Applications/UTM.app/
        sleep .5
    fi
}

function stop_templateVM (){
    if [[ $(utmctl status $NAME)=="started" ]]; then                            # checks if template is running
        utmctl stop $NAME
        sleep .2
    fi
}

function delete_VMcopy (){
    if [[ $(utmctl status ${NAME}_${SUFFIX})=="started" ]]; then                # checks if copy is running  
        utmctl stop ${NAME}_${SUFFIX}
        sleep .5
    fi

    utmctl delete ${NAME}_${SUFFIX}
}

function check_delete_existing_VMcopy (){  
    while ( utmctl list | grep ${NAME}_${SUFFIX} ); do                          # checks if copy already exists
        if [ $? -eq 0 ]; then
            delete_VMcopy
        fi
    done
}

function clone_templateVM (){                                                   # clones template
    utmctl clone $NAME --name ${NAME}_${SUFFIX} 
    sleep .2
}

function launch_VMcopy (){                                                      # launches copy
    utmctl start ${NAME}_${SUFFIX}
    sleep .50
}

function share_screen (){                                                       # starts screen sharing
    open vnc://${USER}:${PASSWORD}@$HOSTNAME                                    # (vnc://[user]:[password]@[server]:[port])
}


#   script   #
start_apachectl                                   
changeto_munki_dev_repo
change_munki_repo_preferences 
update_repo &> /dev/null
open_utm
stop_templateVM &> /dev/null
###delete_VMcopy &> /dev/null                                                   # runs in check_delete_existing_VMcopy
check_delete_existing_VMcopy &> /dev/null
clone_templateVM 
launch_VMcopy
share_screen                                                                    # bug wenn JAMF enrollt ist -> manuelles munki enrollment


#   testing   #
#echo "Hostname: $HOSTNAME"
#echo "Name: $NAME"
#echo "Username: $USER"
#echo "Password: $PASSWORD"
echo "Script setup_server completed."