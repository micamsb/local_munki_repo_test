#!/bin/zsh --no-rcs

#creates VM clone from template and starts it
#run on local machine with UTM installed and Template VM imported

##template VM    name: lmsw    user: lmsw    password: lmsw   language: en    hostname: lmsws-Virtual-Machine.local

#Variabeln
name="lmsw"
user="lmsw"
password="lmsw"
hostname="${name}s-Virtual-Machine.local"       ##different hostname structure for different languages!
#language="en"

##########      #würde so nicht funktionieren aber auch nicht wirklich relevant für uns
#if[$language="en"]
#    hostname="${name}s-Virtual-Machine.local"
#fi
#if[$language="de"]
#    hostname="Virtuelle-Maschine-von-$name.local"
#fi
##########


#/Applications/UTM.app/Contents/MacOS/utmctl
#sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl

#Opens UTM
open /Applications/UTM.app/

        ###Template importieren, da hostname über .local läuft?
#Downloads the newest template version and opens it in UTM
###wget command evtl
#cp remoteserver///Library/Containers/UTM/Data/Documents/${name}.utm ~/Library/Containers/UTM/Data/Documents         ### Remote server connection muss bestehen
### mv ~/Downloads/${name}.utm ~/Library/Containers/UTM/Data/Documents/${name}.utm 
### utmctl open ~/Library/Containers/UTM/Data/Documents/${name}.utm     #wird durch mv richtig abgelegt und später gestartet


#Stops the template VM if it is running
if [[ $(utmctl status $name)=="started" ]]
then
    utmctl stop $name
fi

#Clones and starts new VM
utmctl clone $name --name ${name}_clone 
utmctl start ${name}_clone
sleep .15

#creates a screen sharing connection with the VM using VNC
open vnc://$user:$password@$hostname        ## vnc://[user]:[password]@[hostname]:[port]     #port not required? (port=5900 ?)
### Man muss sich dann noch in der VM einloggen -> noch kein command dafür gefunden


##starts the template VM to update it with the productive repo?? ...
#utmctl start $name 
#utmctl exec --input    #...

##stops and deletes cloned VM?? ...
#utmcl stop ${name}_clone
#utmctl delete ${name}_clone
    ### sonst entstehen immer mehr kopien die eigentlich nicht mehr gebraucht werden
    ### darf erst ausgefürt werden wenn man fertig ist -> Im hintergrund laufen lassen bis z.B. 3h idle modus   oder Zweites, automatisiertes skript das jeden morgen läuft und die alten VMs löscht?