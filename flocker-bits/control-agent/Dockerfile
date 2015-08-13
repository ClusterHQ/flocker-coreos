FROM ubuntu:14.04
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

env CONTROL_HOSTNAME=ec2-52-27-159-173.us-west-2.compute.amazonaws.com

RUN sudo apt-get update
RUN sudo apt-get -y install apt-transport-https software-properties-common
RUN sudo add-apt-repository -y ppa:james-page/docker
RUN sudo add-apt-repository -y "deb https://clusterhq-archive.s3.amazonaws.com/ubuntu/$(lsb_release --release --short)/\$(ARCH) /"
RUN sudo apt-get update
RUN sudo apt-get -y --force-yes install clusterhq-flocker-cli
RUN sudo apt-get -y --force-yes install clusterhq-flocker-node

RUN sudo echo "start on runlevel [2345]" > /etc/init/flocker-control.override
RUN sudo echo "stop on runlevel [016]" >> /etc/init/flocker-control.override

RUN sudo bash -c "echo 'flocker-control-api	4523/tcp	# Flocker Control API port' >> /etc/services"
RUN sudo bash -c "echo 'flocker-control-agent	4524/tcp	# Flocker Control Agent port' >> /etc/services"
