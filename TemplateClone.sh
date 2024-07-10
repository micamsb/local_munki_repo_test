#!/bin/zsh --no-rcs

#creates VM clone from template and starts it
#run on local machine with UTM installed and Template VM imported

##template VM    name: lmsw    user: lmsw    password: lmsw   language: en    hostname: lmsws-Virtual-Machine.local


#   variables   #
name="lmsw"
user="lmsw"
password="lmsw"
hostname="${name}s-Virtual-Machine.local"       #different hostname pattern for different languages!
#language="en"


#   functions   #
function activate_utmctl (){
    /Applications/UTM.app/Contents/MacOS/utmctl
    sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl
}

function open_utm(){
    if ps -A | grep -v grep | grep -iq 'utm.app'
    then 
        sleep 2
    else 
        open /Application/UTM.app/
        sleep 5
    fi
}

        ###Template importieren, da hostname über .local läuft?
#Downloads the newest template version and opens it in UTM
###wget command evtl
#cp remoteserver///Library/Containers/UTM/Data/Documents/${name}.utm ~/Library/Containers/UTM/Data/Documents         ### Remote server connection muss bestehen
### mv ~/Downloads/${name}.utm ~/Library/Containers/UTM/Data/Documents/${name}.utm 
### utmctl open ~/Library/Containers/UTM/Data/Documents/${name}.utm     #wird durch mv richtig abgelegt und später gestartet

function stop_templateVM (){
    if [[ $(utmctl status $name)=="started" ]]
    then
        utmctl stop $name
        sleep 2
    fi
}

function clone_templateVM (){
    utmctl clone $name --name ${name}_clone 
    sleep 2
}

function launch_VMcopy (){
   utmctl start ${name}_clone
    sleep 5 
}

function share_screen (){
    open vnc://$user:$password@$hostname        # vnc://[user]:[password]@[hostname]:[port]     #port not required? (port=5900 ?)
}       ### Man muss sich dann noch in der VM einloggen -> noch kein command dafür gefunden

function update_templateVM (){  #starts the template VM to update it with the productive repo?? ...
    if [[ $(utmctl status $name)=="stopped" ]]
    then    
        utmctl start $name
        sleep 5
    fi

    utmctl exec --input     #... 
}

function delete_VMcopy(){   #stops and deletes cloned VM?? ...  #sonst entstehen immer mehr kopien die veraltet sind; dürfte erst ausgefürt werden wenn man fertig ist (automatisches skript das jede woche läuft?)
    if [[ $(utmctl status ${name}_clone)=="started" ]]
    then    
        utmctl stop ${name}_clone
        sleep 5
    fi

    utmctl delete ${name}_clone
}


#   script  #
open_utm

stop_templateVM

clone_templateVM

launch_VMcopy

share_screen

