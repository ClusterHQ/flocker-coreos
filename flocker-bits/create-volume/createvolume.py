"""
Some useful things
"""

from utils import (url_factory, get_request_factory, post_request_factory,
    get_volume_create_data, loop_until, inject_dashes_to_uuid, compare_host_uuids)
import treq
import json
from twisted.internet import reactor, defer

"""
def get_nodes(client):
  d1 = client.get(base_url + "/configuration/datasets")
  d1.addCallback(treq.json_content)
"""

# the uuid used for a node when the volume should float between nodes
FAKE_NODE_UUID = "00000000-0000-0000-0000-000000000000"

def create_volume(settings, client):
    url = url_factory(settings)
    get_request = get_request_factory(client, url)
    post_request = post_request_factory(client, url)

    def dataset_exists(data):
        print json.dumps(data)

    def check_if_dataset_exists():
        d = get_request('/state/datasets')
        def check_dataset_exists(datasets):
            matching_dataset = None
            for dataset in datasets:
                if dataset["dataset_id"] == settings["dataset_uuid"]:
                    matching_dataset = dataset

            if matching_dataset is None:
                return None

            if not "primary" in matching_dataset:
                return None

            if compare_host_uuids(matching_dataset["primary"], settings['host_uuid']):
                return matching_dataset
            else:
                return None
        d.addCallback(check_dataset_exists)
        return d

    def create_dataset():
        def dataset_created(data):
            if 'errors' in data and data['errors'] is not None:
                raise Exception(data['errors'])
            d = loop_until(check_if_dataset_exists)
            d.addCallback(dataset_exists)
            return d

        volume_data = get_volume_create_data(
            settings['host_uuid'],
            settings['dataset_uuid'],
            settings['size']
        )
        d = post_request('/configuration/datasets', volume_data)
        d.addCallback(dataset_created)
        return d

    def move_dataset():
        def dataset_unattached(data):
            if 'errors' in data and data['errors'] is not None:
                raise Exception(data['errors'])

        def dataset_moved(data):
            if 'errors' in data and data['errors'] is not None:
                raise Exception(data['errors'])
            d = loop_until(check_if_dataset_exists)
            d.addCallback(dataset_exists)
            return d
        move_data = {
            "primary":inject_dashes_to_uuid(settings['host_uuid'])
        }
        d = post_request('/configuration/datasets/%s' % (settings['dataset_uuid']), move_data)
        if settings['host_uuid'] == FAKE_NODE_UUID:
            d.addCallback(dataset_unattached)
        else:
            d.addCallback(dataset_moved)
        return d

    def get_dataset_configuration():
        d = get_request('/configuration/datasets')
        return d

    def check_move_or_create():
        d = get_dataset_configuration()
        def process_dataset_configs(datasets):
            does_dataset_exist = False
            for dataset in datasets:
                if dataset['dataset_id'] == settings['dataset_uuid']:
                    does_dataset_exist = True
            if does_dataset_exist:
                return move_dataset()
            else:
                return create_dataset()

        d.addCallback(process_dataset_configs)
        return d

    def does_node_exists(nodes):
        if settings['host_uuid'].lower() == 'none':
            settings['host_uuid'] = FAKE_NODE_UUID
            return True
        have_seen_node = False
        for node in nodes:
            if compare_host_uuids(node['uuid'], settings['host_uuid']):
                have_seen_node = True
        return have_seen_node

    def node_data_loaded(node_data):
        if not does_node_exists(node_data):
            raise Exception("the host %s does not exist" % (settings['host_uuid']))            
        return check_move_or_create()

    def get_node_data():
        d = get_request('/state/nodes')
        d.addCallback(node_data_loaded)
        return d

    return get_node_data()