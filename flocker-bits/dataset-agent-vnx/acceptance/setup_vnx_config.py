# Copyright ClusterHQ Inc.  See LICENSE file for details.

"""
A quick hack to put VNX storage group and host settings on to each host.
"""

from subprocess import check_output


class VNX(object):
    def __init__(self, host, group, ports):
        self.host = host
        self.group = group
        self.ports = ports


vnx_hosts = [
    VNX(
        host='esx08.ashqe',
        group='Docker100',
        ports=[
            '0x21000024ff02d323',
            '0x21000024ff02d229',
        ]
    ),
    VNX(
        host='esx07.ashqe',
        group='Docker101',
        ports=[
            '0x21000024ff02d2cd',
            '0x21000024ff02d2ce',
        ]
    ),
    VNX(
        host='esx10.ashqe',
        group='Docker102',
        ports=[
            '0x21000024ff02d2f0',
            '0x21000024ff02d1e0',
        ]
    ),
    VNX(
        host='esx05.ashqe',
        group='Docker103',
        ports=[
            '0x21000024ff02d284',
            '0x21000024ff02d1dc',
        ]
    ),
    VNX(
        host='esx01.ashqe',
        group='Docker104',
        ports=[
            '0x21000024ff02d1dd',
            '0x21000024ff02d1d9',
        ]
    ),
    VNX(
        host='esx09.ashqe',
        group='Docker106',
        ports=[
            '0x21000024ff02d208',
            '0x21000024ff02d265',
        ]
    ),
]

ports_to_vnx_hosts = dict(
    (tuple(host.ports), host)
    for host in vnx_hosts
)


coros_hosts = list(
    '172.20.20.%s' % (i,)
    for i in range(100, 107)
)


def coreos_ssh(host, command):
    return check_output(['ssh', 'core@%s' % (host,), command])


def parse_ports(raw):
    return tuple(
        line
        for line in raw.splitlines()
        if line
    )


def main():
    for host in coros_hosts:
        print "CONFIGURING", host
        ports = parse_ports(
            coreos_ssh(host, 'cat /sys/class/fc_host/host*/port_name')
        )
        if ports in ports_to_vnx_hosts:
            vnx_config = ports_to_vnx_hosts[ports]
        else:
            print "WARNING: Missing VNX configuration for", host
            continue
        coreos_ssh(
            host,
            """
            mkdir -p /home/core/etc_flocker/vnx_settings
            echo "{vnx.host}" > /home/core/etc_flocker/vnx_settings/host
            echo "{vnx.group}" > /home/core/etc_flocker/vnx_settings/group
            """.format(vnx=vnx_config)
        )


if __name__ == '__main__':
    raise SystemExit(main())
