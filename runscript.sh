#!/bin/bash

red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'
magenta='\e[1;35m%s\e[0m\n'
cyan='\e[1;36m%s\e[0m\n'

export DISPLAY=":0"

# Import github ssh keys if flag is set
if [ ! -z ${SSH+x} ];
then
    ssh-keygen -A
    ssh-import-id-gh $SSH
    printf "\n$green" "You can ssh in to the container with something like the following:"
    printf "\n$cyan" '  ssh -C -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -L 5900:localhost:5900 root@server -p 2222'
    printf "\n$green" "Once you've ssh'ed in, you should be able to open up VNC with a command like so:"
    printf "\n$cyan" '  vncviewer localhost:5900'
    printf "\n$red" "VNC access is passwordless because access is via ssh."
fi


# Set TWS username if flag is set
if [ ! -z ${USERNAME+x} ];
then
    printf "\n$green" "Setting TWS username"
    sed -i "/IbLoginId=/c\IbLoginId=$USERNAME" /home/broker/ibc/config.ini
fi

# Set TWS password if flag is set
if [ ! -z ${PASSWORD+x} ];
then
    printf "\n$green" "Setting TWS password"
    sed -i "/IbPassword=/c\IbPassword=$PASSWORD" /home/broker/ibc/config.ini
fi

# Set TWS username if flag is set
if [ ! -z ${TRADINGMODE+x} ];
then
    printf "\n$green" "Setting trading mode"
    sed -i "/TradingMode=/c\TradingMode=$TRADINGMODE" /home/broker/ibc/config.ini
fi

# start up supervisord, all daemons should launched by supervisord.
printf "\n$cyan" "Starting supervisord"
/usr/bin/supervisord -c /etc/supervisord.conf

printf "\n$cyan" "Sleeping 5 seconds"
sleep 3

# needed to run parameters CMD
$@
