#!/bin/zsh --no-rcs


# Create folder structure
SERVER_ROOT=/Users/Shared/munki_repo

mkdir $SERVER_ROOT
mkdir $SERVER_ROOT/catalogs
mkdir $SERVER_ROOT/icons
mkdir $SERVER_ROOT/manifests
mkdir $SERVER_ROOT/pkgs
mkdir $SERVER_ROOT/pkgsinfo

chmod -R a+rX $SERVER_ROOT

sudo ln -s $SERVER_ROOT /Library/WebServer/Documents/

sudo apachectl start


####################
#auf VM
####################


apachectl status  #man braucht mod-status um den status abzurufen :/
if[$? -ne 1]  #$? = exit code of recent command; 1 = failed??; 0 = sucess??; -> if apache not on then start start it; -ne = not equal
#argument aus dem exit code herausfiltern damit nur an / aus als aoutput kommt
    sudo apachectl start
fi


sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false #Aktiviert Permission zum ScreenSharing

hostname #gibt den hostnamen --> wird gebraucht um verbindung mit VNC herzustellen


###############
#local
###############

/Applications/UTM.app/Contents/MacOS/utmctl
sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl

utmctl status lmsw     
if[$?==started]         #geht das ==?
    utmctl stop lmsw
    wait 15
fi

utmctl clone lmsw --name lmswClone # --name scheint nicht zu funktionieren
utmctl start lmswClone

open vnc://lmsw:lmsw@lmsws-Virtual-Machine.local #verbindet sich mithilfe von Screen Sharing mit der VM #vnc://user:password@hostname[:port]

utmctl start lmsw #danach starten, damit locales Repo sich mit dem Prod. Repo updaten kann?? 

