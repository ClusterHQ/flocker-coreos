"""
Some useful things
"""

import treq
import sys
import json
from twisted.internet import reactor
from twisted.internet.defer import maybeDeferred
from twisted.internet.task import deferLater

def url_factory(settings):
    def construct_url(path):
        return "https://%s:%s/v1%s" % (
            settings['target_hostname'],
            settings['target_port'],
            path
        )
    return construct_url

def get_request_factory(client, url):
    def get_request(path):
        d = client.get(url(path))
        d.addCallback(treq.json_content)
        return d
    return get_request

def post_request_factory(client, url):
    def post_request(path, data):
        d = client.post(url(path), json.dumps(data),
            headers={'Content-Type': ['application/json']})
        d.addCallback(treq.json_content)
        return d
    return post_request

def get_volume_create_data(host_uuid, dataset_uuid, size, metadata={}):
    return {
        "primary": host_uuid,
        "dataset_id": dataset_uuid,
        "maximum_size": size,
        "metadata": metadata
    }

def loop_until(predicate):
    """Call predicate every 0.1 seconds, until it returns something ``Truthy``.

    :param predicate: Callable returning termination condition.
    :type predicate: 0-argument callable returning a Deferred.

    :return: A ``Deferred`` firing with the first ``Truthy`` response from
        ``predicate``.
    """
    d = maybeDeferred(predicate)

    def loop(result):
        if not result:
            d = deferLater(reactor, 0.1, predicate)
            d.addCallback(loop)
            return d
        return result
    d.addCallback(loop)
    return d