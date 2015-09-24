#!/opt/flocker/bin/python

# -*- coding: utf-8 -*-
import re
import sys

from flocker.node.script import AgentService, AgentServiceFactory, flocker_container_agent_main

FLOCKER_AGENT_IP = os.environ.get('FLOCKER_AGENT_IP')

if FLOCKER_AGENT_IP is None:
    sys.stderr.write("FLOCKER_AGENT_IP env variable required")
    exit(1)

def get_external_ip_from_env(self, host, port):
    return unicode(FLOCKER_AGENT_IP, "ascii")

AgentService.get_external_ip = get_external_ip_from_env
AgentServiceFactory.get_external_ip = get_external_ip_from_env

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(flocker_container_agent_main())