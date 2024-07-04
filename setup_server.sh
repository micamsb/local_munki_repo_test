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

