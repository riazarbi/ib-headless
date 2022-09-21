#!/bin/bash

# Import github ssh keys if flag is set
if [ ! -z ${SSH+x} ];
then
    echo "Configuring and setting up ssh"
    mkdir /var/run/sshd
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
    ssh-keygen -A
    ssh-import-id-gh $SSH
    echo "You can ssh in to the container with something like the following:"
    echo 'ssh -C -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -L 5900:localhost:5900 root@server -p 2222'
fi

# Set the correct tws path for supervisord
export TWS_MAJOR_VRSN=$(ls ~/Jts/ibgateway/ | sed "s/.*\///")
export DISPLAY=":0"

sed -i "/ibgateway/c\command=/root/Jts/ibgateway/$TWS_MAJOR_VRSN/ibgateway" /etc/supervisord.conf


# start up supervisord, all daemons should launched by supervisord.
/usr/bin/supervisord -c /etc/supervisord.conf &

# Give enough time for a connection before trying to expose on 0.0.0.0:4003
echo "Forking :::4001 onto 0.0.0.0:4003\n"
socat TCP-LISTEN:4003,fork TCP:127.0.0.1:4001
