#!/bin/bash
# SRCDS Container Start Script
#
# Copyright (c) 2016 Dane Everitt <dane@daneeveritt.com>
# MIT Licensed
# ##
sleep 3
if [ "$(pwd)" -ne "/home/container" ]; then
    cd /home/container
fi

# Download SteamCMD, it is missing
if [ ! -f "/home/container/steamcmd/steamcmd.sh" ]; then
    mkdir steamcmd; cd steamcmd

    set -x
    curl -sSL -o steamcmd.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz
    set +x

    if [ "$?" -ne "0" ]; then
        echo "There was an error while attempting to download SteamCMD (exit code: $?)"
        exit 1
    fi

    tar -xzvf steamcmd.tar.gz
    rm -rf steamcmd.tar.gz

    echo "Installing requested game, this could take a long time depending on game size and network."
    set -x
    ./steamcmd.sh +login $SCRDS_USER +password $SCRDS_PASS +force_install_dir /home/container +app_update $SRCDS_APPID +quit
    set +x

    cd /home/container
    mkdir -p .steam/sdk32
    cp -v steamcmd/linux32/steamclient.so .steam/sdk32/steamclient.so
else
    echo "Dependencies in place, to re-download this game please delete steamcmd.sh in the steamcmd directory."
fi

cd /home/container

if [ -z "$STARTUP" ]; then
    echo "No startup command was specified!"
    exit 1
fi

MODIFIED_STARTUP=`echo $STARTUP | perl -pe 's@{{(.*?)}}@$ENV{$1}@g'`
echo "./srcds_run ${MODIFIED_STARTUP}"
./srcds_run $MODIFIED_STARTUP
