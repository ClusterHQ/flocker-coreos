## Containerize Flocker Control Agent.


## Steps:

 * Build image for Flocker Control Agent:

```
$ docker build -t clusterhq/flocker-control-service .
```
See main README for how to run it.

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
