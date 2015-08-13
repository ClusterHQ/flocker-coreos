## flocker-coreos

An experiment in getting Flocker to work on CoreOS.

## objective

To create and mount a filesystem from inside a container and to then access a read/write version of the filesystem from another container.

## spin up Vagrant VM

first start the CoreOS VM:

```bash
$ vagrant up
$ vagrant ssh
```

## manual test

```bash
$ dd if=/dev/zero of=/tmp/my_fs bs=1024 count=30720
$ losetup /dev/loop0 /tmp/my_fs
$ mkfs -t ext4 -m 1 -v /dev/loop0
$ mkdir /testmount
$ mount -t ext4 /dev/loop0 /testmount
```

Now check the volume is empty:

```bash
$ ls -la /testmount
total 17
drwxr-xr-x  3 root root  1024 Aug 12 17:10 .
drwxr-xr-x 24 root root  4096 Aug 12 17:10 ..
drwx------  2 root root 12288 Aug 12 17:10 lost+found
```

Now we run a container using the volume and write to it:

```bash
$ docker run -ti --rm -v /testmount:/data ubuntu sh -c "echo hello > /data/file.txt"
```

Now check that the volume was written to:

```bash
$ ls -la /testmount
total 18
drwxr-xr-x  3 root root  1024 Aug 12 17:11 .
drwxr-xr-x 24 root root  4096 Aug 12 17:10 ..
-rw-r--r--  1 root root     6 Aug 12 17:11 file.txt
drwx------  2 root root 12288 Aug 12 17:10 lost+found
```

Yay - so we have confirmed what we know - manually creating filesystems on the host works well.

Clean up:

```bash
$ umount /testmount
$ losetup -d /dev/loop0
```

## nsenter test

First we create the docker image `ubuntu-nsenter` from the Dockerfile in this repo:

```bash
$ docker build -t ubuntu-nsenter ubuntu-nsenter
```

Next we run the nsenter container mounting the hosts '/proc' folder:

```bash
$ docker run --privileged=true -ti --rm -v /:/host ubuntu-nsenter
```

Next we run the commands from the manual test but `nsentering` each time (to the hosts pid 1):

```bash
$ nsenter --mount=/host/proc/1/ns/mnt -- dd if=/dev/zero of=/tmp/my_fs4 bs=1024 count=30720
$ nsenter --mount=/host/proc/1/ns/mnt -- losetup /dev/loop4 /tmp/my_fs4
$ nsenter --mount=/host/proc/1/ns/mnt -- mkfs -t ext4 -m 1 -v /dev/loop4
$ nsenter --mount=/host/proc/1/ns/mnt -- mkdir /testmount4
$ nsenter --mount=/host/proc/1/ns/mnt -- mount -t ext4 /dev/loop4 /testmount4
$ exit
```

Next we run a container using the newly created mount:

```bash
$ docker run -ti --rm -v /testmount4:/data ubuntu sh -c "echo hello > /data/file.txt"
```
