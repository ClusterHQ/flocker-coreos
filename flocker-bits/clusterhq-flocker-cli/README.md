## Containerize Flocker CA.


## Steps:

 * Build container for Flocker CA and certificates for cluster administrator, control agent, and node agents.

```
$ docker run -ti myechuri/t1
```

 * Alternatively, you can run `flocker-ca` on your local machine.

 * Run Flocker CA container: copy certs in container's home directory into host's /var/lib/flocker/node-etc-flocker/, which will in turn be bind mounted in control agent and node agents' /etc/flocker/ .
