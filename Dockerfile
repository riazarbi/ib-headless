FROM debian:buster

EXPOSE 5900 

ENV HOME /root
ENV TZ Etc/UTC
ENV SHELL /bin/bash
ENV PS1='# '

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y tigervnc-standalone-server \
    openbox \
    tint2 \
    pcmanfm \
    xfce4-terminal \
    supervisor \
    procps \
    curl \
 && apt-get autoclean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /root/.vnc; \
    echo "root" | vncpasswd -f > /root/.vnc/passwd; \
    chmod 600 /root/.vnc/passwd

ADD etc/xdg/pcmanfm /root/.config/pcmanfm
ADD etc /etc

#CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

#FROM ubuntu:18.04

#LABEL maintainer="Riaz Arbi <riazarbi@gmail.com>"

#USER root
ENV TWS_MAJOR_VRSN=978
#ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean \
 && apt-get update \
 && apt-get install -y \
    wget \
    unzip \
    socat \
#    xvfb \
#    libxtst6 \
#    libxrender1 \
#    libxi6 \
#    x11vnc \
#    socat \
#    software-properties-common \
#    dos2unix \
    openssh-server \
    ssh-import-id \
#    supervisor \
#    openbox \
#    vim-tiny \
#    firefox \
#    pwgen \
 && apt-get autoclean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

# Setup IB TWS
RUN mkdir -p /opt/TWS 
WORKDIR /opt/TWS
RUN wget -q https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod a+x ibgateway-stable-standalone-linux-x64.sh

# Install TWS
RUN yes n | /opt/TWS/ibgateway-stable-standalone-linux-x64.sh

WORKDIR /

# Below files copied during build to enable operation without volume mount
COPY ./ib/jts.ini /root/Jts/jts.ini
ADD runscript.sh ./
#ADD supervisord.conf ./

RUN chmod a+x runscript.sh

#CMD bash runscript.sh $TWS_MAJOR_VRSN

EXPOSE 4003
EXPOSE 5900
EXPOSE 22

ENTRYPOINT ["./runscript.sh"]

