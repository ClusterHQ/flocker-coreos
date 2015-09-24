# dataset-agent Dockerfile
FROM clusterhq/flocker-core:1.2.0-1
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

ADD wrap_dataset_agent_mtab.sh /opt/flocker/wrap_dataset_agent_mtab.sh
RUN chmod +x /opt/flocker/wrap_dataset_agent_mtab.sh

CMD ["/opt/flocker/wrap_dataset_agent_mtab.sh"]
