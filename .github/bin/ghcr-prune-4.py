#!/usr/bin/python3
# PYTHON_ARGCOMPLETE_OK
import argparse
import dateutil.parser
import getpass
import os
import requests
import numpy
from datetime import datetime, timedelta

__author__ = "Maxim Verbitskiy"
__version__ = "0.1"
__copyright__ = "Copyright (C) 2021 Fiona Klute"
__license__ = "MIT"

# GitHub API documentation: https://docs.github.com/en/rest/reference/packages
github_api_accept = 'application/vnd.github.v3+json'


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='List versions of a GHCR container image you own, and '
        'optionally delete (prune) old, untagged versions.')
    parser.add_argument('--container', default='crash-js-app',
                        help='name of the container image')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='print extra debug info')
    parser.add_argument('--dry-run', '-n', action='store_true',
                        help='do not actually prune images, just list which '
                        'would be pruned')
    parser.add_argument('--number', type=int, metavar='COUNT', 
                        default=None,
                        help='delete all images instead of COUNT last')
    #parser.add_argument('--token', '-t',
                        #help='add a github token to connect')

    # enable bash completion if argcomplete is available
    try:
        import argcomplete
        argcomplete.autocomplete(parser)
    except ImportError:
        pass

    args = parser.parse_args()

    #token = args.token
    token = os.environ.get('GITHUB_TOKEN')

    s = requests.Session()
    s.headers.update({'Authorization': f'token {token}',
                      'Accept': github_api_accept})

    r = s.get(f'https://api.github.com/orgs/softteco/packages/'
              f'container/{args.container}/versions')
    versions = r.json()
    if args.verbose:
        reset = datetime.fromtimestamp(int(r.headers["x-ratelimit-reset"]))
        print(f'{r.headers["x-ratelimit-remaining"]} requests remaining '
              f'until {reset}')
        print(versions)

    array_of_index_and_datetime_creation = []

    for index, v in enumerate(versions):
        #created = dateutil.parser.isoparse(v['created_at'])
        created = v["created_at"]
        metadata = v["metadata"]["container"]
        #print(f'{v["id"]}\t{v["name"]}\t{created}\t{metadata["tags"]}')
        #test.insert(0,metadata["tags"])
        array_of_index_and_datetime_creation.insert(0,index+1)
        array_of_index_and_datetime_creation.insert(0,v["id"])
        array_of_index_and_datetime_creation.insert(0,created)

    array_of_index_and_datetime_creation.reverse()
    print(array_of_index_and_datetime_creation)
    arr = numpy.array(array_of_index_and_datetime_creation)
    newarr = numpy.array_split(arr,len(versions))
    print(newarr)
    array_of_index_and_datetime_creation_3=sorted(newarr, key=lambda x: x[2], reverse=True)
    print(array_of_index_and_datetime_creation_3)
    
    for index, v in enumerate(array_of_index_and_datetime_creation_3):
        if len(array_of_index_and_datetime_creation_3) > 0 and index>args.number-1:
            if args.dry_run:
                print(f'would delete {v[1]}')
            else:
                r = s.delete(f'https://api.github.com/user/packages/'
                             f'container/{args.container}/versions/{v[1]}')
                r.raise_for_status()
                print(f'deleted {v[1]}')
