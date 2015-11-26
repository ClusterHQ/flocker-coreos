"""
Some useful things
"""
from utils import (
    url_factory, get_request_factory, post_request_factory,
    get_volume_create_data, loop_until, inject_dashes_to_uuid,
    compare_host_uuids,
)

# the uuid used for a node when the volume should float between nodes
FAKE_NODE_UUID = "5749b519-4c60-4ee2-99b2-5ff437e91761"


def node_exists(settings, client):
    url = url_factory(settings)
    get_request = get_request_factory(client, url)
    d = get_request('/state/nodes')

    def state_contains_configured_node(nodes):
        for node in nodes:
            if compare_host_uuids(node['uuid'], settings['host_uuid']):
                return True

        raise Exception(
            "The host %s does not exist" % (settings['host_uuid'],)
        )
    d.addCallback(state_contains_configured_node)
    return d


def dataset_exists(settings, client):
    url = url_factory(settings)
    get_request = get_request_factory(client, url)
    d = get_request('/state/datasets')

    def check_dataset_exists(datasets):
        matching_dataset = None
        for dataset in datasets:
            if dataset["dataset_id"] == settings["dataset_uuid"]:
                matching_dataset = dataset
                break

        if matching_dataset is None:
            return None

        if "primary" not in matching_dataset:
            return None

        if compare_host_uuids(
                matching_dataset["primary"],
                settings['host_uuid'],
        ):
            return matching_dataset
        else:
            return None

    d.addCallback(check_dataset_exists)
    return d


def dataset_not_exists(settings, client):
    url = url_factory(settings)
    get_request = get_request_factory(client, url)
    d = get_request('/state/datasets')
    d.addCallback(
        lambda datasets: len(list(
            dataset for dataset in datasets
            if dataset['dataset_id'] == settings['dataset_uuid']
        )) == 0
    )
    return d


def dataset_detached(settings, client, dataset_id):
    url = url_factory(settings)
    get_request = get_request_factory(client, url)
    d = get_request('/state/datasets')
    d.addCallback(
        lambda datasets: list(
            dataset for dataset in datasets
            if dataset['dataset_id'] == dataset_id
            and 'primary' not in dataset
        )
    )
    return d


def create_dataset(settings, client):
    volume_data = get_volume_create_data(
        settings['host_uuid'],
        settings['dataset_name'],
        settings['dataset_uuid'],
        settings['size']
    )
    url = url_factory(settings)
    post_request = post_request_factory(client, url)
    d = post_request('/configuration/datasets', volume_data)

    def dataset_created(data):
        if 'errors' in data and data['errors'] is not None:
            raise Exception(data['errors'])
        if 'dataset_name' in settings:
            if settings['dataset_name'] is not None:
                settings['dataset_uuid'] = data['dataset_id']
        return loop_until(lambda: dataset_exists(settings, client))
    d.addCallback(dataset_created)
    return d


def move_dataset(settings, client):
    move_data = {
        "primary": inject_dashes_to_uuid(settings['host_uuid'])
    }
    url = url_factory(settings)
    post_request = post_request_factory(client, url)
    d = post_request(
        b'/configuration/datasets/%s' % (
            settings['dataset_uuid'].encode('ascii'),
        ),
        move_data
    )

    def dataset_moved(data):
        if 'errors' in data and data['errors'] is not None:
            raise Exception(data['errors'])
        d = loop_until(lambda: dataset_exists(settings, client))
        return d
    d.addCallback(dataset_moved)
    return d


def _dataset_by_name_or_id(datasets, settings):
    for dataset in datasets:
        if settings['dataset_name'] is not None:
            if 'metadata' in dataset and dataset['metadata'] is not None:
                if 'name' in dataset['metadata']:
                    if dataset['metadata']['name'] is not None:
                        if dataset['metadata']['name'] == settings['dataset_name']:
                            return dataset
        else:
            if dataset['dataset_id'] == settings['dataset_uuid']:
                return dataset


def dataset_by_name_or_id(settings, client):
    url = url_factory(settings)
    get_request = get_request_factory(client, url)
    d = get_request('/configuration/datasets')
    d.addCallback(_dataset_by_name_or_id, settings)
    return d


def _move_or_create(settings, client):
    d = dataset_by_name_or_id(settings, client)

    def decide(dataset):
        if dataset:
            settings['dataset_uuid'] = dataset['dataset_id']
            return move_dataset(settings, client)
        else:
            return create_dataset(settings, client)
    d.addCallback(decide)
    return d


def move_or_create(settings, client):
    d = node_exists(settings, client)
    d.addCallback(
        lambda ignored: _move_or_create(settings, client)
    )
    return d


def detach(settings, client):
    d = dataset_by_name_or_id(settings, client)

    def _detach(dataset):
        move_data = {
            "primary": FAKE_NODE_UUID
        }
        url = url_factory(settings)
        post_request = post_request_factory(client, url)
        return post_request(
            b'/configuration/datasets/%s' % (
                dataset['dataset_id'].encode('ascii'),
            ),
            move_data
        )
    d.addCallback(_detach)

    def wait_for_detach(data):
        if 'errors' in data and data['errors'] is not None:
            raise Exception(data['errors'])
        d = loop_until(
            lambda: dataset_detached(settings, client, data['dataset_id'])
        )
        return d
    d.addCallback(wait_for_detach)
    return d


def delete(settings, client):
    d = dataset_by_name_or_id(settings, client)

    def _delete(dataset):
        url = url_factory(settings)
        if dataset:
            settings['dataset_uuid'] = dataset['dataset_id']
            return client.delete(
                url(b'/configuration/datasets/%s' % (
                    dataset['dataset_id'].encode('ascii'),
                ))
            )
        else:
            raise Exception('Unknown dataset', settings)
    d.addCallback(_delete)
    d.addCallback(
        lambda ignored: loop_until(
            lambda: dataset_not_exists(settings, client)
        )
    )
    return d
