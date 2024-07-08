#!/bin/zsh --no-rcs

##creates VM clone from template and starts it

#/Applications/UTM.app/Contents/MacOS/utmctl
#sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl


if[$(utmctl status lmsw)="started"]
    utmctl stop lmsw
    wait 15
else continue
fi

utmctl clone lmsw --name lmswClone 
utmctl start lmswClone

open vnc://lmsw:lmsw@lmsws-Virtual-Machine.local ##creates a screen sharing connection with the VM using VNC #vnc://user:password@hostname[:port]

#utmctl start lmsw ##starts the template VM to update it with the prod. repo? 
