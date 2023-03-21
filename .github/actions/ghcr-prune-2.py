#!/usr/bin/python3
# PYTHON_ARGCOMPLETE_OK
import argparse
import dateutil.parser
import getpass
import os
import requests
from datetime import datetime, timedelta

__author__ = "Max VeRBiTSKiy"
__version__ = "0.1"
__copyright__ = "Copyright (C) 2021 Fiona Klute"
__license__ = "MIT"

# GitHub API documentation: https://docs.github.com/en/rest/reference/packages
github_api_accept = 'application/vnd.github.v3+json'


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='List versions of a GHCR container image you own, and '
        'optionally delete (prune) old, untagged versions.')
    parser.add_argument('--token', '-t', action='store_true',
                        help='ask for token input instead of using the '
                        'GHCR_TOKEN environment variable')
    parser.add_argument('--container', default='crash-js-app',
                        help='name of the container image')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='print extra debug info')
    #parser.add_argument('--prune-age', type=float, metavar='DAYS',
                        #default=None,
                        #help='delete untagged images older than DAYS days')
    parser.add_argument('--dry-run', '-n', action='store_true',
                        help='do not actually prune images, just list which '
                        'would be pruned')
    parser.add_argument('--number', type=int, metavar='COUNT', 
                        default=None,
                        help='delete all images instead of COUNT last')

    # enable bash completion if argcomplete is available
    try:
        import argcomplete
        argcomplete.autocomplete(parser)
    except ImportError:
        pass

    args = parser.parse_args()

    if args.token:
        token = getpass.getpass('Enter Token: ')
    elif 'GHCR_TOKEN' in os.environ:
        token = os.environ['GHCR_TOKEN']
    else:
        raise ValueError('missing authentication token')

    s = requests.Session()
    s.headers.update({'Authorization': f'token {token}',
                      'Accept': github_api_accept})

    r = s.get(f'https://api.github.com/user/packages/'
              f'container/{args.container}/versions')
    versions = r.json()
    if args.verbose:
        reset = datetime.fromtimestamp(int(r.headers["x-ratelimit-reset"]))
        print(f'{r.headers["x-ratelimit-remaining"]} requests remaining '
              f'until {reset}')
        print(versions)

    for index, v in enumerate(versions):
        created = dateutil.parser.isoparse(v['created_at'])
        metadata = v["metadata"]["container"]
        print(f'{v["id"]}\t{v["name"]}\t{created}\t{metadata["tags"]}')

        # prune old untagged images if requested
        if len(metadata['tags']) > 0 and index>args.number-1:
            if args.dry_run:
                print(f'would delete {v["id"]}')
            else:
                r = s.delete(f'https://api.github.com/user/packages/'
                             f'container/{args.container}/versions/{v["id"]}')
                r.raise_for_status()
                print(f'deleted {v["id"]}')

        # prune old tagged images if requested
        #if del_before is not None and created < del_before \
            #if args.dry_run:
                #print(f'would delete {v["id"]}')
            #else:
                #r = s.delete(f'https://api.github.com/user/packages/'
                             #f'container/{args.container}/versions/{v["id"]}')
                #r.raise_for_status()
                #print(f'deleted {v["id"]}')