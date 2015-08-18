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

RUN sudo echo "#!/bin/bash" > /bin/nsmount
RUN sudo echo "/bin/nsenter --mount=/host/proc/1/ns/mnt -- /bin/mount \"\$@\"" >> /bin/nsmount
RUN sudo echo "#!/bin/bash" > /bin/nsumount
RUN sudo echo "/bin/nsenter --mount=/host/proc/1/ns/mnt -- /bin/umount \"\$@\"" >> /bin/nsumount
RUN sudo echo "#!/bin/bash" > /bin/nslsblk
RUN sudo echo "/bin/nsenter --mount=/host/proc/1/ns/mnt -- /bin/lsblk \"\$@\"" >> /bin/nslsblk
RUN sudo echo "#!/bin/bash" > /sbin/nslosetup
RUN sudo echo "/bin/nsenter --mount=/host/proc/1/ns/mnt -- /sbin/losetup \"\$@\"" >> /sbin/nslosetup
RUN sudo echo "#!/bin/bash" > /sbin/nsmkfs
RUN sudo echo "/bin/nsenter --mount=/host/proc/1/ns/mnt -- /sbin/mkfs \"\$@\"" >> /sbin/nsmkfs
RUN sudo echo "#!/bin/bash" > /sbin/nsblkid
RUN sudo echo "/bin/nsenter --mount=/host/proc/1/ns/mnt -- /sbin/mkfs \"\$@\"" >> /sbin/nsblkid
RUN sudo bash -c "chmod 4755 /bin/nsmount; \
                  chmod 4755 /bin/nsumount; \
                  chmod 755 /bin/nslsblk; \
                  chmod 755 /sbin/nslosetup; \
                  chmod 755 /sbin/nsblkid; \
                  mv /bin/mount /bin/linuxmount; \
                  mv /bin/umount /bin/linuxumount; \
                  mv /bin/lsblk /bin/linuxlsblk; \
                  mv /sbin/losetup /sbin/linuxlosetup; \
                  mv /sbin/mkfs /sbin/linuxmkfs; \
                  mv /sbin/blkid /sbin/linuxblkid; \
                  ln -s /bin/nsmount /bin/mount; \
                  ln -s /bin/nsumount /bin/umount; \
                  ln -s /bin/nslsblk /bin/lsblk; \
                  ln -s /sbin/nslosetup /sbin/losetup; \
                  ln -s /sbin/nsmkfs /sbin/mkfs; \
                  ln -s /sbin/nsblkid /sbin/blkid"

# CMD service flocker-dataset-agent start
# CMD service flocker-control-agent start

# BEGIN - debugging tools
# Please remove after POC for 2 reasons:
# 1. Not needed for Flocker functionality
# 2. Add 100MB to image

# Unofficial Flocker tools
RUN sudo apt-get install -y python-pip build-essential libssl-dev libffi-dev python-dev
RUN sudo pip install git+https://github.com/clusterhq/unofficial-flocker-tools.git
RUN sudo pip install eliot-tree

# Tox - for unit testing storage driver
RUN sudo pip install tox

# END - debugging tools

# 
