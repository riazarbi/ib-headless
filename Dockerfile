FROM debian:buster

LABEL maintainer="Riaz Arbi <riazarbi@gmail.com>"

# Openbox, vnc, ssh
ENV HOME /root
ENV TZ Etc/UTC
ENV SHELL /bin/bash
ENV PS1='# '
ENV DISPLAY=":0"

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

# IBC
ENV IBC_PKG_URL="https://github.com/IbcAlpha/IBC/releases/download/3.14.0/IBCLinux-3.14.0.zip" 

ADD ${IBC_PKG_URL} /tmp/ibc.zip
RUN mkdir -p /opt/ibc/logs \
 && mkdir -p /root/ibc/logs \
 && unzip /tmp/ibc.zip -d /opt/ibc/ \
 && cd /opt/ibc/ \
 && chmod o+x *.sh */*.sh \
 && sed -i 's/     >> \"\${log_file}\" 2>\&1/     2>\&1/g' scripts/displaybannerandlaunch.sh \
 && sed -i 's/light_red=.*/light_red=""/g' scripts/displaybannerandlaunch.sh \
 && sed -i 's/light_green=.*/light_green=""/g' scripts/displaybannerandlaunch.sh \
 && rm -f /tmp/ibc.zip \
 && cp /opt/ibc/config.ini /root/ibc

# Add run script and conf files
ADD etc /etc
ADD runscript.sh ./
ADD ibc/config.ini /root/ibc/config.ini
RUN chmod a+x runscript.sh

# Modify configs for current IB and IBC version
RUN   mkdir /var/run/sshd \
&&    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
&&    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

ENV TWS_MAJOR_VRSN $(ls ~/Jts/ibgateway/ | sed "s/.*\///")
RUN echo  "TWS VERSION INSTALLED: $TWS_MAJOR_VRSN"

RUN sed -i "/ibgateway/c\command=/root/Jts/ibgateway/$TWS_MAJOR_VRSN/ibgateway" /etc/supervisord.conf

# Tell IBC what the TWS version is
RUN sed -i "/TWS_MAJOR_VRSN=1012/c\TWS_MAJOR_VRSN=$TWS_MAJOR_VRSN" /opt/ibc/gatewaystart.sh


ENTRYPOINT ["./runscript.sh"]

EXPOSE 4003
EXPOSE 22
