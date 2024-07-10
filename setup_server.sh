#!/bin/zsh --no-rcs

#creates a folder structure; connects to the dev repo; clones a VM from template and starts it
#run on local machine with UTM installed and Template VM imported (works only if the correct variables are used in template)

##template VM    name: lmsw    user: lmsw    password: lmsw   language: en    hostname: lmsws-Virtual-Machine.local


#   variables   #
name="lmsw"
user="lmsw"
password="lmsw"
hostname="${name}s-Virtual-Machine.local"       #different hostname pattern for different languages!
language="en"
clone_suffix="clone"
suffix=$clone_suffix

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

function activate_screen_sharing (){
    sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false 
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
}       ### macht noch probleme -> muss in den   System Settings >  Sharing > Screen Sharing     nochmal manuell deaktiviert und reaktiviert werden

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

function enable_shared_directory (){
    utmctl new_shared_directory ${name} dav.its-cs-munki-test-01.its.unibas.ch/files/html/munki_repo_dev
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
    utmctl list | grep ${name}_${suffix}

    if [ $? -eq 0 ]
    then
        delete_VMcopy
    fi
}

function clone_templateVM (){
    utmctl clone $name --name ${name}_${suffix} 
    sleep .2
}

function launch_VMcopy (){
   utmctl start ${name}_${suffix}
    sleep .15 
}

function share_screen (){
    open vnc://$user:$password@$hostname        # vnc://[user]:[password]@[hostname]:[port]     #port not required? (port=5900 ?)
}       ### Man muss sich dann noch in der VM einloggen -> noch kein command dafür gefunden


#   script    #                 #Info                                       #trennung           #status
create_folder_structure         #nur ein mal nötig                          #~zeitlich          #funktioniert (auch wenn man die funktion öfter ausführt)

start_apachectl                 #auf VM?                                    #räumlich           #funktioniert aber grosser output der nicht direkt gebraucht wird

activate_utmctl                 #unnötig / nur ein mal nötig                                    #funktioniert

open_utm                                                                                        #funktioniert

#activate_screen_sharing         #funktioniert nur manuel auf VM             #räumlich            #bug

changeto_munki_dev_repo                                                                         #funktioniert

update_repo                     #unnötig?                                                       #funktioniert

#enable_shared_directory         #funktioniert nur manuel auf UTM            #räumlich           #geht nicht        #wichtig

stop_templateVM                                                                                 #funktioniert

#delete_VMcopy                   #in check_existing_VMcopy implementiert     #zeitlich?          #funktioniert in check_delete_existing_VMcopy

check_delete_existing_VMcopy    #löscht kopie falls eine existiert          #                   #funktioniert

clone_templateVM                                                                                #funktioniert

launch_VMcopy                                                                                   #funktioniert

share_screen                                                                                    #funktioniert

echo "Script completed."