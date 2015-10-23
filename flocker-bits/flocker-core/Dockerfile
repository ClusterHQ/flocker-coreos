# container-agent Dockerfile
FROM ubuntu:14.04
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

RUN apt-get update
RUN apt-get -y install apt-transport-https software-properties-common

RUN apt-get -y --force-yes install \
      git \
      build-essential \
      libncurses5-dev \
      libslang2-dev \
      gettext \
      zlib1g-dev \
      libselinux1-dev \
      debhelper \
      lsb-release \
      pkg-config \
      po-debconf \
      autoconf \
      automake \
      autopoint \
      libtool

RUN apt-get -y install git python-pip && \
    cd /tmp && \
    git clone https://github.com/clusterhq/flocker && \
    cd flocker && \
    git checkout etcd-persistency-LABS-105 && \
    pip install . && \
    cd / && \
    rm -rf /tmp/flocker

RUN git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git util-linux

RUN bash -c "cd util-linux; \
                  ./autogen.sh; \
                  ./configure --without-python --disable-all-programs --enable-nsenter; \
                  make"
RUN cp /util-linux/nsenter /bin

ADD wrap_command.sh /tmp/wrap_command.sh

RUN bash /tmp/wrap_command.sh /bin mount 4755
RUN bash /tmp/wrap_command.sh /bin umount 4755
RUN bash /tmp/wrap_command.sh /bin lsblk 755
RUN bash /tmp/wrap_command.sh /sbin losetup 755
RUN bash /tmp/wrap_command.sh /sbin mkfs 755
RUN bash /tmp/wrap_command.sh /sbin blkid 755
