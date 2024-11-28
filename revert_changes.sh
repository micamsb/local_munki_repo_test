#!/bin/zsh --no--rcs

# Script reverts the changes made in the setup_server.sh script.


#   functions   #
function stop_apachectl (){                                                    # stops apachectl server
    launchctl print system/org.apache.httpd

    if [ $? -eq 1 ]; then
        sleep .2
    else 
        sudo apachectl stop
    fi
}

function autopkg_revert_munki_repo_preferences (){
    defaults write com.github.autopkg MUNKI_REPO /Volumes/files/html/munki_repo_dev
}

#   script   #
stop_apachectl &> /dev/null
autopkg_revert_munki_repo_preferences &> /dev/null


#   testing   #
echo "Script revert_changes complete."