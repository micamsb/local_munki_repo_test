#!/bin/zsh --no--rcs

# Script reverts the changes of munki repository preference made for the local munki server workflow


#   functions   #
function stop_apachectl (){                                                    # stops apachectl server
    launchctl print system/org.apache.httpd &> /dev/null

    if [ $? -eq 1 ]; then
        sleep .2
    else 
        sudo apachectl stop
    fi
}

function revert_munki_repo_preferences (){
    defaults write com.github.autopkg MUNKI_REPO /volumes/files/html/munki_repo_dev
}

#   script   #
stop_apachectl
revert_munki_repo_preferences &> /dev/null


#   testing   #
echo "Script revert_changes complete."