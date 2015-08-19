# dataset-agent Dockerfile
FROM clusterhq/flocker-core
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

ADD wrap_dataset_agent_mtab.sh /tmp/wrap_dataset_agent_mtab.sh
RUN chmod +x /tmp/wrap_dataset_agent_mtab.sh

CMD ["/tmp/wrap_dataset_agent_mtab.sh"]
