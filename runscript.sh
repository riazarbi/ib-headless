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
fi

# start up supervisord, all daemons should launched by supervisord.
/usr/bin/supervisord -c /etc/supervisord.conf &

# Give enough time for a connection before trying to expose on 0.0.0.0:4003
echo "Forking :::4001 onto 0.0.0.0:4003\n"
socat TCP-LISTEN:4003,fork TCP:127.0.0.1:4001
