#!/bin/sh

# /etc/mtab is usually linked to /proc/mounts, but here we want to
# "continuously" update it with the *host*'s mtab instead

# prime it, before we go off into the backgrounded subshell
unlink /etc/mtab
/bin/nsenter --mount=/host/proc/1/ns/mnt -- cat /etc/mtab > /etc/mtab

# update mtab atomically every second
(
    while true; do
        /bin/nsenter --mount=/host/proc/1/ns/mnt -- cat /etc/mtab > /etc/mtab.tmp
        mv /etc/mtab.tmp /etc/mtab
        sleep 1
    done
) &

# now start the dataset agent
exec /usr/sbin/flocker-dataset-agent $@
