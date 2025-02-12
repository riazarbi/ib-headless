#!/bin/bash

red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'
magenta='\e[1;35m%s\e[0m\n'
cyan='\e[1;36m%s\e[0m\n'

export DISPLAY=":0"


# Function to read input and trim whitespace
trim() {
    echo "$1" | awk '{$1=$1};1'
}

# Check if TRADINGMODE exists; if not, prompt the user to choose live or paper
if [[ -z "$TRADINGMODE" ]]; then
    echo "Select IB trading mode :"
    select choice in "live" "paper"; do
        if [[ "$choice" == "live" || "$choice" == "paper" ]]; then
            TRADINGMODE=$choice
            break
        else
            echo "Invalid selection. Please choose 1 for live or 2 for paper."
        fi
    done
fi

# Check and prompt for USERNAME if not set
if [[ -z "$USERNAME" ]]; then
    read -p "Enter your IB username: " input
    USERNAME=$(trim "$input")
fi

# Check and prompt for PASSWORD if not set
if [[ -z "$PASSWORD" ]]; then
    read -s -p "Enter your IB password: " input
    PASSWORD=$(trim "$input")
fi

# Set TWS TRADINGMODE if flag is set
if [ ! -z ${TRADINGMODE+x} ];
then
    printf "\n$green" "Setting trading mode: $TRADINGMODE"
    sed -i "/TradingMode=/c\TradingMode=$TRADINGMODE" /home/broker/ibc/config.ini
fi

# Set TWS USERNAME if flag is set
if [ ! -z ${USERNAME+x} ];
then
    printf "$green" "Setting TWS username: $USERNAME"
    sed -i "/IbLoginId=/c\IbLoginId=$USERNAME" /home/broker/ibc/config.ini
fi

# Set TWS PASSWORD if flag is set
if [ ! -z ${PASSWORD+x} ];
then
    printf "$green" "Setting TWS password."
    sed -i "/IbPassword=/c\IbPassword=$PASSWORD" /home/broker/ibc/config.ini
fi

# start up supervisord, all daemons should launched by supervisord.
printf "$cyan" "Starting supervisord"
/usr/bin/supervisord -c /etc/supervisord.conf

printf "$cyan" "Sleeping 5 seconds"
sleep 3

# needed to run parameters CMD
$@
