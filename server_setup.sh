#!/bin/zsh --no-rcs

# To use this script, a UTM VM has to be set up as a template.


#   variables   #
function user_input_variables (){
    echo "Name of the template VM (Press ENTER for 'template' as NAME):"
    read -r NAME
    echo
    if [ -z "$NAME" ]; then
        NAME="template"
    fi

    echo "Password of the template VM (Press ENTER if NAME = PASSWORD):"
    read -r -s PASSWORD
    echo
    if [ -z "$PASSWORD" ]; then
        PASSWORD="$NAME"
    fi

    LANGUAGE="en"                                                                   # different hostname pattern for different languages!
    SUFFIX="clone"
    HOSTNAME="${NAME}s-Virtual-Machine.local"                                       # for ${LANGUAGE}=="en"
    SERVER_ROOT=/Users/Shared/munki_repo
}


#   functions   #
function create_folder_structure (){
    if [ ! -d $SERVER_ROOT ]; then
        mkdir $SERVER_ROOT
        mkdir $SERVER_ROOT/catalogs
        mkdir $SERVER_ROOT/icons
        mkdir $SERVER_ROOT/manifests
        mkdir $SERVER_ROOT/pkgs
        mkdir $SERVER_ROOT/pkgsinfo

        chmod -R a+rX $SERVER_ROOT

        sudo ln -s $SERVER_ROOT /Library/WebServer/Documents/
        echo "Creating Directory:" $SERVER_ROOT
    fi
}

function activate_utmctl (){ 
    if [ ! -L /usr/local/bin/utmctl ]; then
        #/Applications/UTM.app/Contents/MacOS/utmctl &> /dev/null
        sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl
        echo "Creating a symbolic link for utmctl."
    fi
}

function start_apachectl (){                                                    # starts apachectl server
    launchctl print system/org.apache.httpd &> /dev/null

    if [ $? -eq 0 ]; then
        sleep .2
    else 
        sudo apachectl start
    fi
}

function autopkg_change_munki_repo_preferences (){
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
    open vnc://${NAME}:${PASSWORD}@$HOSTNAME                                    # (vnc://[user]:[password]@[server]:[port])
}


#   script   #
user_input_variables
create_folder_structure
activate_utmctl
start_apachectl                                   
autopkg_change_munki_repo_preferences 
update_repo &> /dev/null
open_utm
stop_templateVM &> /dev/null
###delete_VMcopy &> /dev/null                                                   # runs in check_delete_existing_VMcopy
check_delete_existing_VMcopy &> /dev/null
clone_templateVM 
launch_VMcopy
share_screen                                                                    # bug wenn JAMF enrollt ist -> manuelles munki enrollment


#   testing   #
#echo "Name: $NAME"
#echo "Password: $PASSWORD"
#echo "Hostname: $HOSTNAME"
echo "Script server_setup completed."