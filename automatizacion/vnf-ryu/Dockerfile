FROM ubuntu:bionic
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# install required packages
RUN apt-get clean
RUN apt-get update \
    && apt-get install -y  git \
    net-tools \
    aptitude \
    build-essential \
    python-setuptools \
    python-dev \
    python-pip \
    software-properties-common \
    ansible \
    curl \
    iptables \
    iputils-ping \
    sudo \
    nano \
    bridge-utils \
    isc-dhcp-server \
    tcpdump \
    openvswitch-switch \
    iperf3 \
    vim \
    iproute2 \
    ryu-bin

COPY dhcpd.conf /etc/dhcp/dhcpd.conf
COPY isc-dhcp-server /etc/default/isc-dhcp-server
COPY qos_simple_switch_13.py /qos_simple_switch_13.py

#Install isc-dhcp-server
#RUN apt-get update
#RUN apt-get install isc-dhcp-server 
#RUN apt-get update
#RUN apt-get install isc-dhcp-relay

# open ports
# IPERF3
EXPOSE 5201
# IPERF3
EXPOSE 3000
# IPERF3
EXPOSE 7000
