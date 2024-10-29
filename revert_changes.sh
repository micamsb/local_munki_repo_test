#!/bin/zsh --no--rcs

# Script reverts the changes of munki repository preference made for the local munki server workflow


#   functions   #
function revert_munki_repo_preferences (){
    defaults write com.github.autopkg MUNKI_REPO /volumes/files/html/munki_repo_dev
}

#   script   #
revert_munki_repo_preferences &> /dev/null


#   testing   #
echo "Script revert_changes complete."