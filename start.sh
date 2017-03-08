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

function install-rocketmod {
	if [ "$SRCDS_GAME" == "Unturned" ]; then
		if [ ! -f "/home/container/RocketLauncher.exe" ]; then
			wget "https://api.rocketmod.net/download.unturned-linux.latest.DC24040A-0AB8-4207-B068-3DCE1194CD4A" -O /home/container/rocketmod.zip
			unzip rocketmod.zip -d . && rm -f rocketmod.zip
			mv Scripts/*.sh .
		fi
	fi
}

# Download SteamCMD, it is missing
if [ ! -f "/home/container/steamcmd/steamcmd.sh" ]; then
	if [ ! -d "/home/container/steamcmd" ]; then
		mkdir /home/container/steamcmd
	fi
	if [ "$SRCDS_GAME" == "Unturned" ]; then
		if [ ! -d "/home/container/unturned" ]; then
			mkdir /home/container/unturned
		fi
		installdir="/home/container/unturned"
	fi
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
    ./steamcmd.sh +login $SRCDS_EMAIL +force_install_dir $installdir +app_update $SRCDS_APPID +quit
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
#./srcds_run $MODIFIED_STARTUP
./Unturned.x86_64 -nographics -pei -normal -nosync -pve -players:16 -ip:$SERVER_IP -port:$SERVER_PORT
