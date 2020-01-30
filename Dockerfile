FROM ubuntu:18.04

LABEL maintainer="Riaz Arbi <riazarbi@gmail.com>"

USER root
ENV IBC_PATH=/opt/IBController
ENV LOG_PATH=/opt/IBController/Logs

ENV TZ=Africa/Johannesburg
ENV VNC_PASSWORD=1234
ENV TWS_MAJOR_VRSN=972
ENV IBC_INI=/root/IBController/IBController.ini
ENV IBC_PATH=/opt/IBController
ENV TWS_PATH=/root/Jts
ENV TWS_CONFIG_PATH=/root/Jts
ENV LOG_PATH=/opt/IBController/Logs
ENV TRADING_MODE=paper 
ENV TWSUSERID=fdemo 
ENV TWSPASSWORD=demouser 
ENV FIXUSERID=
ENV FIXPASSWORD=
ENV APP=GATEWAY


RUN DEBIAN_FRONTEND=noninteractive \
    apt-get clean \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get update \
 && apt-get install -y \
    wget \
    unzip \
    xvfb \
    libxtst6 \
    libxrender1 \
    libxi6 \
    x11vnc \
    socat \
    software-properties-common \
    dos2unix \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Setup IB TWS
RUN mkdir -p /opt/TWS 
WORKDIR /opt/TWS
RUN wget -q https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod a+x ibgateway-stable-standalone-linux-x64.sh

# Setup  IBController
WORKDIR /opt/IBController/
RUN mkdir -p /opt/IBController/ \
 && mkdir -p /root/IBController/Logs 
RUN wget -q https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip
RUN unzip ./IBController-3.4.0.zip
RUN chmod -R u+x *.sh && chmod -R u+x Scripts/*.sh

WORKDIR /

# Install TWS
RUN yes n | /opt/TWS/ibgateway-stable-standalone-linux-x64.sh
RUN sed -i "s/TWS_MAJOR_VRSN=.*/TWS_MAJOR_VRSN=972/g" /opt/IBController/IBControllerStart.sh \
 && sed -i "s/TWS_MAJOR_VRSN=.*/TWS_MAJOR_VRSN=972/g" /opt/IBController/IBControllerGatewayStart.sh

RUN echo 972 > version

# Set up VNC
ENV DISPLAY :0

ADD runscript.sh runscript.sh
ADD ./vnc/xvfb_init /etc/init.d/xvfb
ADD ./vnc/vnc_init /etc/init.d/vnc
ADD ./vnc/xvfb-daemon-run /usr/bin/xvfb-daemon-run

RUN chmod -R u+x runscript.sh \
  && chmod -R 777 /usr/bin/xvfb-daemon-run \
  && chmod 777 /etc/init.d/xvfb \
  && chmod 777 /etc/init.d/vnc

RUN dos2unix /usr/bin/xvfb-daemon-run \
  && dos2unix /etc/init.d/xvfb \
  && dos2unix /etc/init.d/vnc \
  && dos2unix runscript.sh

# Below files copied during build to enable operation without volume mount
COPY ./ib/IBController.ini /root/IBController/IBController.ini
COPY ./ib/jts.ini /rooty/Jts/jts.ini

CMD bash runscript.sh

# Expose ports
EXPOSE 4003
EXPOSE 5900




