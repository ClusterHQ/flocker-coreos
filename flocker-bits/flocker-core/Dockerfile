# container-agent Dockerfile
FROM ubuntu:14.04
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

RUN sudo apt-get update
RUN sudo apt-get -y install apt-transport-https software-properties-common
RUN sudo add-apt-repository -y ppa:james-page/docker
RUN sudo add-apt-repository -y "deb https://clusterhq-archive.s3.amazonaws.com/ubuntu/$(lsb_release --release --short)/\$(ARCH) /"
RUN sudo apt-get update
RUN sudo apt-get -y --force-yes install clusterhq-flocker-cli
RUN sudo apt-get -y --force-yes install clusterhq-flocker-node

RUN sudo apt-get -y --force-yes install git build-essential libncurses5-dev libslang2-dev gettext zlib1g-dev libselinux1-dev debhelper lsb-release pkg-config po-debconf autoconf automake autopoint libtool

RUN sudo git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git util-linux
RUN sudo bash -c "cd util-linux; \
                  ./autogen.sh; \
                  ./configure --without-python --disable-all-programs --enable-nsenter; \
                  make"
RUN sudo cp /util-linux/nsenter /bin

ADD wrap_command.sh /tmp/wrap_command.sh

RUN bash /tmp/wrap_command.sh /bin mount 4755
RUN bash /tmp/wrap_command.sh /bin umount 4755
RUN bash /tmp/wrap_command.sh /bin lsblk 755
RUN bash /tmp/wrap_command.sh /sbin losetup 755
RUN bash /tmp/wrap_command.sh /sbin mkfs 755
RUN bash /tmp/wrap_command.sh /sbin blkid 755
