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
$ docker run --privileged -v /:/host -v /var/lib/flocker/node-etc-flocker:/etc/flocker -v /dev:/dev -v /usr/bin/docker:/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -ti myechuri/anode
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
