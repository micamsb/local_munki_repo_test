#!/bin/zsh --no-rcs


##prüfen ob apachectl läuft bevor aktivierung

##ergebnis immer fehler
status="$(netstat -at | grep LISTEN | grep *.http)"
count="$(echo "${status}" | grep -Ev "^$" | wc -l)"

if [ ${count} -eq 0 ] ; then
    echo " Apache server is not running"
fi   

echo "${status}" | 
while IFS= read -r line
do
    echo " ${line}"
done



##andere möglichkeit --> wenn kein ergebnis: apache ist aus
ps aux | grep httpd # | grep root




##anders, geht nicht
apachectl status  ##man braucht mod-status um den status abzurufen :/
if[$? -ne 1]  ##$? = exit code of recent command; 1 = failed??; 0 = sucess??; -> if apache not on then start start it; -ne = not equal
##argument aus dem exit code herausfiltern damit nur an / aus als aoutput kommt
    sudo apachectl start
fi


#anders
apachectl start
if[$? -eq 1] ##falls apache schon gestarted ist, kommt eine fehlermeldung = 1 -> wird ignoriert und skript geht weiter, wenn apache nicht gestartet wird er gestartet
    continue
else 
    continue
fi





#sollte gehen
launchctl print system/org.apache.httpd
if [$? -eq 1]
    sudo apachectl start
fi

