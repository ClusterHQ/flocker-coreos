## Containerize Flocker Node Agents.


## Steps:

 * Build image for Flocker Node Agent:

```
$ docker build -t myechuri/anode .
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

 * Start Flocker Node Agent as a privileged container:

```
$ docker run --privileged -v /:/host -v /var/lib/flocker/node-etc-flocker:/etc/flocker -v /dev:/dev -ti myechuri/anode
```

Please do not change "-v /:/host" part: nsenter wrapper scripts running inside the container rely on "/:/host" mapping.

 * At the command line prompt, start dataset and container agents:

```
# /usr/sbin/flocker-dataset-agent --logfile=/var/log/flocker/flocker-dataset-agent.log &
# /usr/sbin/flocker-container-agent --logfile=/var/log/flocker/flocker-container-agent.log &

```

TODO: Explore why service start yields unrecognized service:

```
root@849ca1785bf5:/etc/init# service flocker-dataset-agent start
flocker-dataset-agent: unrecognized service
```
