#!/bin/bash

red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'
magenta='\e[1;35m%s\e[0m\n'
cyan='\e[1;36m%s\e[0m\n'


# Import github ssh keys if flag is set
if [ ! -z ${SSH+x} ];
then
    printf "\n$green" "Configuring and setting up ssh"
    mkdir /var/run/sshd
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
    ssh-keygen -A
    ssh-import-id-gh $SSH
    printf "\n$green" "You can ssh in to the container with something like the following:"
    printf "\n$cyan" '  ssh -C -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -L 5900:localhost:5900 root@server -p 2222'
    printf "\n$green" "Once you've ssh'ed in, you should be able to open up VNC with a command like so:"
    printf "\n$cyan" '  vncviewer localhost:5900'
    printf "\n$red" "VNC access is passwordless because access is via ssh."
fi

# Set the correct tws path for supervisord
export TWS_MAJOR_VRSN=$(ls ~/Jts/ibgateway/ | sed "s/.*\///")
export DISPLAY=":0"

sed -i "/ibgateway/c\command=/root/Jts/ibgateway/$TWS_MAJOR_VRSN/ibgateway" /etc/supervisord.conf


# Set TWS username if flag is set
if [ ! -z ${USERNAME+x} ];
then
    printf "\n$green" "Setting TWS username"
    sed -i "/IbLoginId=/c\IbLoginId=$USERNAME" /root/ibc/config.ini
fi

# Set TWS password if flag is set
if [ ! -z ${PASSWORD+x} ];
then
    printf "\n$green" "Setting TWS password"
    sed -i "/IbPassword=/c\IbPassword=$PASSWORD" /root/ibc/config.ini
fi

# Set TWS username if flag is set
if [ ! -z ${TRADINGMODE+x} ];
then
    printf "\n$green" "Setting trading mode"
    sed -i "/TradingMode=/c\TradingMode=$TRADINGMODE" /root/ibc/config.ini
fi

# start up supervisord, all daemons should launched by supervisord.
/usr/bin/supervisord -c /etc/supervisord.conf &

# Give enough time for a connection before trying to expose on 0.0.0.0:4003
sleep 30
printf "\n$green" "Forking :::4001 onto 0.0.0.0:4003\n"
socat TCP-LISTEN:4003,fork TCP:127.0.0.1:4001

