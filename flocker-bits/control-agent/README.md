## Containerize Flocker Control Agent.


## Steps:

 * Build container for Flocker Control Agent:

```
$ docker build -t myechuri/cnode .
```

 * Setup control agent certs on CoreOS host in /var/lib/flocker/control-etc-flocker

```
core@ip-172-31-40-181 /var/lib/flocker $ ls /var/lib/flocker/control-etc-flocker
cluster.crt  control-service.crt  control-service.key
```
 * Verify CoreOS host ports 4523-4524 have security policies setup for external access.

 * Start Flocker Control Agent as a privileged container:

```
$ docker run --privileged -v /:/host -p 4523-4524:4523-4524 -v /var/lib/flocker/control-etc-flocker:/etc/flocker -ti myechuri/cnode
```

Please do not change "-v /:/host" part: nsenter wrapper scripts running inside the container rely on "/:/host" mapping.

 * Start control agent:

```
# /usr/sbin/flocker-control -p tcp:4523 -a tcp:$4524 --logfile=/var/log/flocker/flocker-control.log &
```

TODO: Explore why service start yields unrecognized service:

```
root@01909071f062:/etc/flocker# service flocker-control start
flocker-control: unrecognized service
```
