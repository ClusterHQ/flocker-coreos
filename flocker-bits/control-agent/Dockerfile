FROM ubuntu:14.04
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

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

RUN sudo apt-get -y --force-yes install git build-essential libncurses5-dev libslang2-dev gettext zlib1g-dev libselinux1-dev debhelper lsb-release pkg-config po-debconf autoconf automake autopoint libtool

RUN sudo git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git util-linux
RUN sudo bash -c "cd util-linux; \
                  ./autogen.sh; \
                  ./configure --without-python --disable-all-programs --enable-nsenter; \
                  make"
RUN sudo cp /util-linux/nsenter /bin

RUN sudo echo "#!/bin/bash" > /bin/nsmount
RUN sudo echo "/bin/nsenter --mount=/proc/1/ns/mnt -- /bin/linuxmount \"\$@\"" >> /bin/nsmount
RUN sudo chmod 4755 /bin/nsmount
RUN sudo mv /bin/mount /bin/linuxmount
RUN sudo ln -s /bin/nsmount /bin/mount
