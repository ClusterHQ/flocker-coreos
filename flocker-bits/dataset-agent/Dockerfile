# dataset-agent Dockerfile
FROM clusterhq/flocker-core
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

ADD wrap_dataset_agent_mtab.sh /tmp/wrap_dataset_agent_mtab.sh

CMD ["/usr/sbin/flocker-dataset-agent"]
