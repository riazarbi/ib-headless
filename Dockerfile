FROM debian:buster

LABEL maintainer="Riaz Arbi <riazarbi@gmail.com>"

# Openbox, vnc, ssh
ENV HOME /root
ENV TZ Etc/UTC
ENV SHELL /bin/bash
ENV PS1='# '

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    tigervnc-standalone-server \
    openbox \
    tint2 \
    supervisor \
    procps \
    curl \
    openssh-server \
    ssh-import-id \
 && apt-get autoclean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /root/.vnc
    #echo "root" | vncpasswd -f > /root/.vnc/passwd; \
    #chmod 600 /root/.vnc/passwd

#ADD etc/xdg/pcmanfm /root/.config/pcmanfm

# IB TWS
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean \
 && apt-get update \
 && apt-get install -y \
    wget \
    unzip \
    socat \
 && apt-get autoclean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/TWS 

WORKDIR /opt/TWS
RUN wget -q https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod a+x ibgateway-stable-standalone-linux-x64.sh
RUN yes '' | /opt/TWS/ibgateway-stable-standalone-linux-x64.sh

WORKDIR /

# Below files copied during build to enable operation without volume mount
COPY ./ib/jts.ini /root/Jts/jts.ini

#ENV TWS_MAJOR_VRSN $(ls /root/Jts/ibgateway/ | sed "s/.*\///")

# Add run script and conf files
ADD etc /etc
ADD runscript.sh ./
RUN chmod a+x runscript.sh

ENTRYPOINT ["./runscript.sh"]

EXPOSE 4003
EXPOSE 22
