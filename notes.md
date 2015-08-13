## flocker-coreos

An experiment in getting Flocker to work on CoreOS.

## research

### GiantSwarm research

This was sent by Dennis from GiantSwarm:

I did some research on the mount namespace sharing topic for the shared mount problem. even in `systemd-nspawn` container root filesystems are locked down with the `MS_SLAVE` flag. That's effectively the same thing `libcontainer` does. So we cannot use `systemd-nspawn` to hack around the problem. these are the most relevant resources i found about this:

 * a blog post describing `libcontainer`'s problem - https://huaminchen.wordpress.com/2015/05/19/how-docker-handles-mount-namespace/
 * the loc being responsible for libcontainers behaviour - https://github.com/docker/libcontainer/blob/2a94c82423222761fe7b15681d2e4d9aeae8d3bd/rootfs_linux.go#L340
 * An issue on the docker repo mentioning this problem. - https://github.com/docker/docker/issues/10088
 * Lennart Poettering describing how `system-nspawn` handles mount namespaces - http://lists.freedesktop.org/archives/systemd-devel/2012-November/007356.html
 * `systemd`'s code being responsible for this - https://github.com/systemd/systemd/blob/dde8bb32b12c855509777ce52ff59a835155ac78/src/core/namespace.c#L520
 * Kernel's documentation about shared subtrees - https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt
 * The mount(2) man page - http://linux.die.net/man/2/mount

### Rob research

This is the work Rob from ClusterHQ has done on trying to get this to work with NSEnter:

 * a fork of Flocker - https://github.com/ClusterHQ/flocker/compare/nsenter-mount
 * a Docker image that runs Flocker - https://github.com/robhaswell/flocker-coreos-docker

### Luke research

This is the work Luke from ClusterHQ has done to install ZFS on CoreOS:

 * zfs-binaries - https://github.com/ClusterHQ/zfs-binaries

### Kai research

#### Manually create filesystem

 * manually mounting a filesystem onto a loopback block device - https://samindaw.wordpress.com/2012/03/21/mounting-a-file-as-a-file-system-in-linux/

```bash
$ # create a new block device
$ dd if=/dev/zero of=/tmp/my_fs bs=1024 count=30720
$ # check that this loopback device is not already used
$ losetup /dev/loop0
$ # create the loopback device in /dev
$ losetup /dev/loop0 /tmp/my_fs
$ # create a filesystem on the device
$ mkfs -t ext4 -m 1 -v /dev/loop0
$ # mount the device
$ mkdir /testmount
$ mount -t ext4 /dev/loop0 /testmount
$ # unmount the device
$ umount /testmount
$ losetup -d /dev/loop0
```

#### Installing nsenter in an Ubuntu container

CentOS already has nsenter

```
$ ## in the docker
$ apt-get update
$ apt-get install git build-essential libncurses5-dev libslang2-dev gettext zlib1g-dev libselinux1-dev debhelper lsb-release pkg-config po-debconf autoconf automake autopoint libtool
$ git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git util-linux
$ cd util-linux/
$ ./autogen.sh
$ ./configure --without-python --disable-all-programs --enable-nsenter
$ make
```

#### FUSE

http://www.tldp.org/LDP/khg/HyperNews/get/fs/vfstour.html

https://en.wikipedia.org/wiki/Virtual_file_system

kernel has vfs which is mapping between syscalls -> devices
maps filesystems -> inodes
vfs has branch that hooks into fuse
fuse already comes with kernel


#### other folks trying the same

 * https://groups.google.com/forum/#!topic/docker-user/en2Qy1brv0Y

### Madhuri research

 * Docker PR (https://github.com/docker/docker/pull/14097) that enables MS_SHARED rootfs mount option. Sample usage dscribed in https://huaminchen.wordpress.com/2015/07/31/latest-status-on-docker-mount-propagation-development/ 
