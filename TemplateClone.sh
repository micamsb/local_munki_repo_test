#!/bin/zsh --no-rcs

#clones a template VM in UTM
#run on local machine with UTM installed and Template VM imported

##template VM    name: lmsw    user: lmsw    password: lmsw   language: en    hostname: lmsws-Virtual-Machine.local


#   variables   #
name="lmsw"
user="lmsw"
password="lmsw"
hostname="${name}s-Virtual-Machine.local"       #different hostname pattern for different languages!
language="en"


#   functions   #
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

function import_templateVM (){  # ... 
    scp [username]@[remote_ip]:/file/to/send/${name}.utm ~/Library/Containers/UTM/Data/Documents
    ###wget command evtl
    #cp remoteserver///Library/Containers/UTM/Data/Documents/${name}.utm ~/Library/Containers/UTM/Data/Documents         ### Remote server connection muss bestehen
}

function stop_templateVM (){
    if [[ $(utmctl status $name)=="started" ]]
    then
        utmctl stop $name
        sleep .2
    fi
}

function clone_templateVM (){
    utmctl clone $name --name ${name}_clone 
    sleep .2
}

function launch_VMcopy (){
   utmctl start ${name}_clone
    sleep .15 
}

function share_screen (){
    open vnc://$user:$password@$hostname        # vnc://[user]:[password]@[hostname]:[port]     #port not required? (port=5900 ?)
}       ### Man muss sich dann noch in der VM einloggen -> noch kein command dafür gefunden

function update_templateVM (){  #starts the template VM to update it with the productive repo?? ...     #unnötig wenn shared directory funktioniert
    if [[ $(utmctl status $name)=="stopped" ]]
    then    
        utmctl start $name
        sleep .5
    fi

    utmctl exec --input     #... 
}

function delete_VMcopy (){   #stops and deletes cloned VM?? ...  
    if [[ $(utmctl status ${name}_clone)=="started" ]]
    then    
        utmctl stop ${name}_clone
        sleep .5
    fi

    utmctl delete ${name}_clone
}


#   script  #
#activate_utmctl

open_utm

#import_templateVM 

stop_templateVM

clone_templateVM

launch_VMcopy

share_screen

#update_templateVM

#delete_VMcopy

echo "Script completed."