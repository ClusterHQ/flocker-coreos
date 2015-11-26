## A containerized Flocker dataset management CLI

## Steps:

 * Build image for Flocker Dataset Agent:

```
$ docker build -t clusterhq/volume-cli .
```


## Usage:

```
$ ls -1
172.20.20.102
172.20.20.103
cluster.crt
cluster.key
user.crt
user.key
```

```
docker run --rm \
       --env FLOCKER_API_CERT_NAME=user \
       --env FLOCKER_CONTROL_SERVICE_ENDPOINT=172.20.20.102 \
       --volume $PWD:/etc/flocker \
       clusterhq/volume-cli:1.8.0 \
       move_or_create \
           --host-uuid=5f8bc90c-37c7-4810-8461-90c88ec84dd4 \
           --dataset-name=richardw7 \
           --size=7 \
           --size-units=gb
```

```
$ docker run -t -v $PWD:/pwd clusterhq/uft flocker-volumes --control-service=172.20.20.102 ls
DATASET                                SIZE         METADATA         STATUS         SERVER
13af37d3-4b37-4d44-9f89-00c4cecb11c0   <no quota>   name=richardw1   attached ✅   96815587 (172.20.20.103)
ad7cd462-f3de-4a71-ae06-ceebf1a5723d   2.00G        name=richardw2   attached ✅   5f8bc90c (172.20.20.102)
2ed80e18-b63d-4210-9c5c-2e8caac953b9   1.00G                         attached ✅   5f8bc90c (172.20.20.102)
1e867160-e17d-4b73-aea2-e6fe008da8e2   6.00G        name=richardw6   attached ✅   96815587 (172.20.20.103)
8fef5d97-84b5-47c1-911e-6f2d9363b2f0   3.00G        name=richardw3   attached ✅   5f8bc90c (172.20.20.102)
aa81e0b9-fd04-4d38-8f28-c41dc90bda1e   4.00G        name=richardw4   attached ✅   96815587 (172.20.20.103)
d884c7ef-293f-4350-9a72-9911719bf652   7.00G        name=richardw7   attached ✅   96815587 (172.20.20.103)
```
