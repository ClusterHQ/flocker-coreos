# container-agent Dockerfile
FROM clusterhq/flocker-core:1.2.0-1rev1
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

ADD flocker-container-agent /usr/sbin/flocker-container-agent
RUN chmod +x /usr/sbin/flocker-container-agent

CMD ["/usr/sbin/flocker-container-agent"]
