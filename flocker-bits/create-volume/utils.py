"""
Some useful things
"""

import treq
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
        d = client.post(
            url(path),
            json.dumps(data),
            headers={'Content-Type': ['application/json']}
        )
        d.addCallback(treq.json_content)
        return d
    return post_request


def inject_dashes_to_uuid(uuid):
    if uuid.find('-') == -1:
        parts = [uuid[0:8], uuid[8:12], uuid[12:16], uuid[16:20], uuid[20:32]]
        uuid = '-'.join(parts)
    return uuid


def compare_host_uuids(id1, id2):
    return (
        id1.replace('-', '').lower()
        == id2.replace('-', '').lower()
    )


def get_volume_create_data(host_uuid, dataset_name, dataset_uuid, size,
                           metadata={}):
    if dataset_name is not None:
        metadata['name'] = dataset_name

    host_uuid = inject_dashes_to_uuid(host_uuid)

    data = {
        "primary": host_uuid,
        "maximum_size": size,
        "metadata": metadata
    }

    if dataset_uuid is not None:
        data['dataset_id'] = dataset_uuid

    return data


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
