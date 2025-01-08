FROM debian:stable

LABEL maintainer="Riaz Arbi <riazarbi@gmail.com>"

# Create broker user
RUN useradd -mUs /bin/bash broker

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /home/broker
ENV TZ Etc/UTC
ENV SHELL /bin/bash
ENV PS1='# '

# Openbox, vnc
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    tigervnc-standalone-server \
    openbox \
    tint2 \
    supervisor \
    procps \
    curl \
    nano \
    novnc \
    websockify \
    git \
# maybe remove?
   dbus-x11 \
 && apt-get autoclean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

USER broker
RUN mkdir /home/broker/.vnc
USER root

# IB TWS ################################

RUN apt-get clean \
 && apt-get update \
 && apt-get install -y \
    wget \
    unzip \
    socat \
 && apt-get autoclean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/TWS \
 && chown -R broker:broker /opt

USER broker
WORKDIR /opt/TWS
RUN wget -q https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod a+x ibgateway-stable-standalone-linux-x64.sh
RUN yes '' | /opt/TWS/ibgateway-stable-standalone-linux-x64.sh

WORKDIR /home/broker

# IBC ##################################
ENV IBC_PKG_URL="https://github.com/IbcAlpha/IBC/releases/download/3.20.0/IBCLinux-3.20.0.zip" 

RUN wget -q -O /home/broker/ibc.zip ${IBC_PKG_URL}
RUN mkdir -p /opt/ibc/logs \
 && mkdir -p /home/broker/ibc/logs \
 && unzip /home/broker/ibc.zip -d /opt/ibc/ \
 && cd /opt/ibc/ \
 && chmod o+x *.sh */*.sh \
 && sed -i 's/     >> \"\${log_file}\" 2>\&1/     2>\&1/g' scripts/displaybannerandlaunch.sh \
 && sed -i 's/light_red=.*/light_red=""/g' scripts/displaybannerandlaunch.sh \
 && sed -i 's/light_green=.*/light_green=""/g' scripts/displaybannerandlaunch.sh \
 && rm -f /home/broker/ibc.zip \
 && cp /opt/ibc/config.ini /home/broker/ibc

# Add run script and conf files
USER root
ADD etc /etc
ADD runscript.sh ./
ADD ibc/config.ini /home/broker/ibc/config.ini
RUN chmod a+x runscript.sh

# Modify configs for current IB and IBC version
RUN export TWS_MAJOR_VRSN=$(ls /home/broker/Jts/ibgateway/ | sed "s/.*\///") \
&&  echo  "TWS VERSION INSTALLED: $TWS_MAJOR_VRSN" \
&& sed -i "/ibgateway/c\command=/root/Jts/ibgateway/$TWS_MAJOR_VRSN/ibgateway" /etc/supervisord.conf \
# Tell IBC what the TWS version is
&& sed -i "/TWS_MAJOR_VRSN=/c\TWS_MAJOR_VRSN=$TWS_MAJOR_VRSN" /opt/ibc/gatewaystart.sh

# TWS API CLIENT ##########################
ENV TWSAPI_CLIENT="https://interactivebrokers.github.io/downloads/twsapi_macunix.1030.01.zip"
RUN wget -q -O /home/broker/twsclient.zip ${TWSAPI_CLIENT} \
 && unzip /home/broker/twsclient.zip -d /home/broker/twsclient \
 && cd /home/broker/twsclient/IBJts/source/pythonclient && python3 setup.py install

# Fix permissions #########################
RUN touch /supervisor.log
RUN chown -R broker:broker /home/broker 
RUN chown -R broker:broker /opt
RUN chmod -R +x /opt/ibc
WORKDIR "/home/broker"
RUN ls -lh

ENV DISPLAY=":0"
EXPOSE 4003
EXPOSE 22

USER broker

ENTRYPOINT ["./runscript.sh"]
CMD ["/opt/ibc/gatewaystart.sh -inline"]
