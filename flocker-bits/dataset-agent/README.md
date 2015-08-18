## Containerize Flocker Dataset Agent


## Steps:

 * Build image for Flocker Dataset Agent:

```
$ docker build -t clusterhq/flocker-dataset-agent .
```

 * Setup  agent certs on CoreOS host in /var/lib/flocker/node-etc-flocker

```
$ ls /var/lib/flocker/node-etc-flocker
agent.yml  cluster.crt  node.crt  node.key
$ cat /var/lib/flocker/node-etc-flocker/agent.yml 
"version": 1
"control-service":
   "hostname": "ec2-52-27-159-173.us-west-2.compute.amazonaws.com"
   "port": 4524
dataset:
    backend: "aws"
    region: "us-west-2"
    zone: "us-west-2b"
    access_key_id: "xxxx"
    secret_access_key: "xxx"
```

 * Start Flocker Dataset Agent as a privileged container:

```
$ docker run --net=host --privileged -v /:/host -v /var/lib/flocker/node-etc-flocker:/etc/flocker -v /dev:/dev -ti clusterhq/flocker-dataset-agent
```

Please do not change "-v /:/host" part: nsenter wrapper scripts running inside the container rely on "/:/host" mapping.

 * At the command line prompt, start dataset agent:

```
# /usr/sbin/flocker-dataset-agent --logfile=/var/log/flocker/flocker-dataset-agent.log &

```

TODO: Explore why service start yields unrecognized service:

```
root@849ca1785bf5:/etc/init# service flocker-dataset-agent start
flocker-dataset-agent: unrecognized service
```
 * Verify that /flocker directory exists on the CoreOS host where the container is running.
