import argparse
import sys
import treq
import os
from client import get_client
from createvolume import create_volume
from twisted.internet import reactor
from twisted.internet.task import react

MINIMUM_DATASET_SIZE = 67108864

def get_constants():
    values = {
        'target_port':4523
    }
    return values

def get_environment():
    env_map = {
        'target_hostname':'FLOCKER_CONTROL_SERVICE_ENDPOINT'
    }
    values = {}

    for property_name, env_name in env_map.iteritems():
        env_value = os.getenv(env_name)
        if env_value is None:
            raise Exception("%s env variable is required" % (env_name))
        values[property_name] = env_value

    return values

def get_arguments():

    parser = argparse.ArgumentParser(description="Create a Flocker dataset "
        + "and wait until it shows up in /v1/state/datasets")

    parser.add_argument('--dataset-uuid',
                        dest='dataset_uuid',
                        type=str,
                        required=True,
                        help='the UUID of the dataset')
    parser.add_argument('--host-uuid',
                        dest='host_uuid',
                        type=str,
                        required=True,
                        help='the UUID of the host for the dataset')
    parser.add_argument('--size',
                        dest='size',
                        type=int,
                        required=True,
                        help='the size of the dataset in bytes')

    args = parser.parse_args()
    return vars(args)

"""
combine the environment settings with the command line arguments into one dict
"""
def get_settings():
    constants = get_constants()
    env = get_environment()
    args = get_arguments()
    settings = dict(env.items() + args.items() + constants.items())
    return settings

def main(reactor):
    settings = get_settings()
    client = get_client()
    return create_volume(settings, client)

if __name__ == "__main__":
    react(main)