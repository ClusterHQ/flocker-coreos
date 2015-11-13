#!/bin/bash

# /etc/mtab is usually linked to /proc/mounts, but here we want to
# "continuously" update it with the *host*'s mtab instead

# prime it, before we go off into the backgrounded subshell
unlink /etc/mtab
/bin/nsenter --mount=/host/proc/1/ns/mnt -- cat /etc/mtab > /etc/mtab

if [[ ${DEBUG} = "1" ]]
then
  >&2 echo "primed mtab"
fi

# update mtab atomically every second
(
    while true; do
        /bin/nsenter --mount=/host/proc/1/ns/mnt -- cat /etc/mtab > /etc/mtab.tmp
        mv /etc/mtab.tmp /etc/mtab

        if [[ ${DEBUG} = "1" ]]
        then
          >&2 echo "updated mtab"
        fi

        sleep 1
    done
) &

# XXX naviseccli -secfilepath expects the current hostname to be the same as at
# the time the credentials were cached. So we override the hostname inside the
# container.
# Can't use docker run --hostname=foo.bar because that option conflicts with
# docker run --net=host.
if test -e /etc/flocker/hostname; then
    hostname -F /etc/flocker/hostname
fi

# now start the dataset agent
exec /usr/sbin/flocker-dataset-agent $@
