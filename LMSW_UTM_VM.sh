#!/bin/zsh
#set -x

#################
#   Variables   #
#################

utmApp="/Applications/UTM.app"

if [ -x /usr/local/bin/utmctl ]; then
    utmCTL="/usr/local/bin/utmctl"
else
    utmCTL="${utmApp}/Contents/MacOS/utmctl"
fi

templatePrefix="TEMPLATE"

thisScript="${0}"

#################
#   Functions   #
#################

function print_usage(){
    if [ ! -z "$2" ]; then
        echo "$2"
        echo ""
    fi
    grep '#\\' "${thisScript}" | grep -v 'grep'
    exit "$1"
	 
 }
 

 function open_utm(){
     if ps -A | grep -v grep | grep -iq 'utm.app' ; then
         sleep 2
     else
         open "$utmApp"
         echo "Opening UTM.app"
         sleep 15
     fi
 }



 function copy_vm(){
     newVMName="${disposablePrefix}_${operatingSystem}_${version}_$(date +%s)"
     "$utmCTL" clone "$templateVMUUID" --name "$newVMName"
     echo "New VM Created: $newVMName"
 }

 function launch_vm(){
     echo "Launching: $finalVM"
 }


 function get_template_vm_UUID(){
     # $1 is the operating system
     # $2 is the version

     # Get the list of VMs
     utmList=$("$utmCTL" list | awk NR\>1)
     templateVMName="${templatePrefix}_${operatingSystem}_${version}"
     # Parse the list of VMs for our VM Template Name and set UUID variable
     templateVMUUID=$(echo "$utmList"| grep "$templateVMName" | awk '{print $1}')
    
     # If we have no matches or multiple matches exit with an error.
     if [ -z $templateVMUUID ]; then
         print_usage 6 "ERROR: Template VM Does not exist: $templateVMName"
     elif [[ $(echo "$templateVMUUID" | wc -l | xargs ) != 1 ]]; then
         print_usage 7 "ERROR: Multiple matches for template VM: $templateVMName"
     fi
 }
 
 function start_vm(){
     if $noStart; then
         echo "VM not started due to option"
         exit 0
     fi

     $utmCTL start "$newVMName"
     sleep 5
     if [[ $("$utmCTL" status "$newVMName") != 'started' ]]; then
         echo "ERROR: VM not started as expected."
         exit 6
     fi

 }


 ##########################
 #   Script Starts Here   #
 ##########################

 # Prerequisites
 if [[ $(id -u) = 0 ]]; then
     print_usage 8 "ERROR: Cannot run as root"
 fi

 #\ Arguments
 if [ -z "${1}" ]; then
     echo "Default options will be used."
 fi

 while [ ! -z "${1}" ]; do
     case "$1" in
         -m|--macOS|--macos|--MACOS)                         #\ Spin up a macOS VM - This option is default if no OS is specified
             operatingSystem="macOS" ; shift
             ;;
         -v|--version)                                       #\ What version of the specified OS to spin up. (i.e. 11, 12, 13, 14)
                                                             #\ If not supplied, the host version of macOS is used or the version of Windows
                                                             #\ specified in the script configuration section.
             version="${2}"; shift; shift
             ;;
         -n|-ns|--nostart)                                   #\ Do not start the VM after cloning
             noStart=true; shift
             ;;
         -h|--help)                                          #\ Print this help info
             print_usage 0
             ;;
         *)                                                  #\ Any unknown arguments cause the script to exit.
             print_usage
             exit 9
             ;;
     esac
 done
 
 # Set variables
 if [ -z "$operatingSystem" ]; then
     operatingSystem="macOS"
 fi

 # If no version is set, use determine the appropriate default
 #if [ -z "$version" ] && [[ "$operatingSystem" == "macOS" ]]; then
 #    version=$(sw_vers | grep "ProductVersion" | awk '{print $NF}' | cut -d '.' -f 1)
 #fi
 
 if [ -z "$version" ]; then
     case $operatingSystem in
         macOS)
             version=$(sw_vers | grep "ProductVersion" | awk '{print $NF}' | cut -d '.' -f 1)
             ;;
	       *)
	            echo "Unknown operating system - Exiting"
	            exit 6
	            ;;
	    esac
	fi
 
	# If "No Start" was not set, put the variable to false
	if [ -z $noStart ]; then
	    noStart=false
	fi

	open_utm

	get_template_vm_UUID

	copy_vm

	#start_vm

	echo "Script complete"
 
 
 