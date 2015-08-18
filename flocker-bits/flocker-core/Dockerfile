# container-agent Dockerfile
FROM clusterhq/ubuntu-nsenter
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

RUN sudo apt-get update
RUN sudo apt-get -y install apt-transport-https software-properties-common
RUN sudo add-apt-repository -y ppa:james-page/docker
RUN sudo add-apt-repository -y "deb https://clusterhq-archive.s3.amazonaws.com/ubuntu/$(lsb_release --release --short)/\$(ARCH) /"
RUN sudo apt-get update
RUN sudo apt-get -y --force-yes install clusterhq-flocker-cli
RUN sudo apt-get -y --force-yes install clusterhq-flocker-node

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
RUN sudo echo "/bin/nsenter --mount=/host/proc/1/ns/mnt -- /sbin/blkid \"\$@\"" >> /sbin/nsblkid
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
