## Containerize Flocker CA.


## Steps:

 * Build container for Flocker CA and certificates for cluster administrator, control agent, and node agents.

```
$ docker run -ti myechuri/t1
```

 * Run Flocker CA container: copy certs in container's home directory into host's /var/opt/flocker/certs/, which will in turn be bind mounted in control agent and node agents' /etc/flocker/ .
