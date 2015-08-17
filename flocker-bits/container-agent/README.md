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

 * Start Flocker Control Agent as a privileged container:

```
$ docker run --privileged -v /:/host -v /var/lib/flocker/node-etc-flocker:/etc/flocker -v /dev:/dev -v /var/run/docker.sock:/var/run/docker.sock -ti myechuri/anode
```

Please do not change "-v /:/host" part: nsenter wrapper scripts running inside the container rely on "/:/host" mapping.

 * At the command line prompt, start container agent:

```
# /usr/sbin/flocker-container-agent --logfile=/var/log/flocker/flocker-container-agent.log &

```

 * Verify that container agent log asserts successful communication with control agent:

```
# grep cluster_state /var/log/flocker/flocker-container-agent.log 

{"task_uuid": "43a4b311-bb3c-4b86-88c4-09bc943fe6ab", "cluster_state": "DeploymentState(nodes=NodestatePSet([NodeState(used_ports=IntPSet([32837]), applications=ApplicationPSet([]), paths=UnicodeFilepathPMap({}), manifestations=UnicodeManifestationPMap({}), hostname=u'172.17.1.60', uuid=UUID('bc21cd39-732b-49b6-8575-d912fc746b54'), devices=UuidFilepathPMap({}))]), nonmanifest_datasets=UnicodeDatasetPMap({}))", "action_type": "flocker:agent:converge", "desired_configuration": "Deployment(nodes=NodePSet([]))", "timestamp": 1439835552.535309, "action_status": "started", "task_level": [2, 1]}
```

 * Verify docker works fine from inside container-agent container:

```
root@5b011be0d512:/# docker ps
CONTAINER ID        IMAGE                   COMMAND             CREATED             STATUS              PORTS                                            NAMES
5b011be0d512        myechuri/anode:latest   "/bin/bash"         4 seconds ago       Up 4 seconds                                                         sad_leakey          
b9e4813c715e        myechuri/anode:latest   "/bin/bash"         15 minutes ago      Up 15 minutes                                                        admiring_franklin   
397ae681a196        myechuri/cnode:latest   "/bin/bash"         16 minutes ago      Up 16 minutes       0.0.0.0:4523->4523/tcp, 0.0.0.0:4524->4524/tcp   focused_thompson    
root@5b011be0d512:/#
```
