## Containerize Flocker CA.


## Steps:

 * Build container for Flocker Control Agent:

```
$ docker build -t myechuri/cnode .
```

 * Start Flocker Control Agent as a privileged container:

```
$ docker run --privileged -v /:/host -ti myechuri/cnode
```
