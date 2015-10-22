# dataset-agent Dockerfile
FROM clusterhq/flocker-core:1.2.0-1rev1
MAINTAINER Madhuri Yechuri <madhuri.yechuri@clusterhq.com>

ADD wrap_dataset_agent_mtab.sh /opt/flocker/wrap_dataset_agent_mtab.sh
RUN chmod +x /opt/flocker/wrap_dataset_agent_mtab.sh

ADD flocker-dataset-agent /usr/sbin/flocker-dataset-agent
RUN chmod +x /usr/sbin/flocker-dataset-agent

# this is for the VNX driver
RUN mkdir -p /flocker-vnx-driver
RUN apt-get install -y sg3-utils wget python2.7 python-setuptools
RUN wget https://github.com/emc-openstack/naviseccli/raw/master/navicli-linux-64-x86-en-us_7.33.2.0.51-1_all.deb
RUN dpkg -i navicli-linux-64-x86-en-us_7.33.2.0.51-1_all.deb
RUN git clone https://github.com/ClusterHQ/flocker-vnx-driver.git /flocker-vnx-driver
RUN cd /flocker-vnx-driver && python setup.py install

CMD ["/opt/flocker/wrap_dataset_agent_mtab.sh"]
