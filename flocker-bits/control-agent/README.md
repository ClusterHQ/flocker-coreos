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
$ docker run --net=host --privileged -v /:/host -p 4523-4524:4523-4524 -v /var/lib/flocker/control-etc-flocker:/etc/flocker -ti myechuri/cnode
```

Please do not change "-v /:/host" part: nsenter wrapper scripts running inside the container rely on "/:/host" mapping.

 * Start control agent:

```
# /usr/sbin/flocker-control -p tcp:4523 -a tcp:4524 --logfile=/var/log/flocker/flocker-control.log &
```

TODO: Explore why service start yields unrecognized service:

```
root@01909071f062:/etc/flocker# service flocker-control start
flocker-control: unrecognized service
```

 * Check health of Flocker cluster:

Find IP of control service:
```
root@4640ccbb7437:/# cat /etc/hosts
172.17.1.57	4640ccbb7437
```

Use ``flocker-volumes`` to test dataset workflow:
```
root@4640ccbb7437:/# flocker-volumes --certs-path=/etc/flocker --control-service=172.17.1.57 --control-port=4523 list
DATASET   SIZE   METADATA   STATUS   SERVER 

root@4640ccbb7437:/# flocker-volumes --certs-path=/etc/flocker --control-service=172.17.1.57 --control-port=4523 list-nodes
SERVER     ADDRESS     
bc21cd39   172.17.1.58 

root@4640ccbb7437:/# flocker-volumes --certs-path=/etc/flocker --control-service=172.17.1.57 --control-port=4523 create --node=bc21cd39
created dataset in configuration, manually poll state with 'flocker-volumes list' to see it show up.

root@4640ccbb7437:/# flocker-volumes --certs-path=/etc/flocker --control-service=172.17.1.57 --control-port=4523 list                  
DATASET                                SIZE         METADATA   STATUS        SERVER                 
e6b21850-5637-4db0-b215-813c2c30cba2   <no quota>              pending ⌛   bc21cd39 (172.17.1.58) 
```
