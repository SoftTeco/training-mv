import argparse
import json
import os
from datetime import datetime

import requests

__author__ = "Max VeRBiTSKiy"
__version__ = "0.1"
__copyright__ = "Copyright (C) 2021 Fiona Klute"
__license__ = "MIT"

# GitHub API documentation: https://docs.github.com/en/rest/reference/packages
github_api_accept = "application/vnd.github.v3+json"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="List versions of a GHCR container image you own, and optionally delete old, untagged versions.")
    parser.add_argument("--container", default="front-end", help="name of the container image")
    parser.add_argument("--verbose", "-v", action="store_true", help="print extra debug info")
    parser.add_argument("--dry-run", "-n", action="store_true", help="do not actually prune images, just list which would be pruned")
    parser.add_argument("--number", type=int, metavar="COUNT", default=0, help="delete all images instead of COUNT last")
    parser.add_argument("--token", "-t", help="add a github token to connect")

    # enable bash completion if argcomplete is available
    try:
        import argcomplete

        argcomplete.autocomplete(parser)
    except ImportError:
        pass

    args = parser.parse_args()

    if args.token:
        token = args.token
    elif os.environ.get("GITHUB_TOKEN"):
        token = os.environ.get("GITHUB_TOKEN")
    else:
        raise ("GitHub token must be set via environment variable or via argument.")

    session = requests.Session()
    session.headers.update({"Authorization": f"token {token}", "Accept": github_api_accept})

    request = session.get(f"https://api.github.com/orgs/softteco/packages/container/{args.container}/versions")
    versions = request.json()

    if args.verbose:
        reset = datetime.fromtimestamp(int(request.headers["x-ratelimit-reset"]))
        print(f"{request.headers['x-ratelimit-remaining']} requests remaining until {reset}")
        print(json.dumps(versions, indent=2))

    sorted_versions = sorted(versions, key=lambda x: x["created_at"], reverse=True)

    for idx in range(args.number, len(sorted_versions)):
        if args.dry_run:
            print(f"Version with id={sorted_versions[idx]['id']} will be deleted")
        else:
            request = session.delete(f"https://api.github.com/user/packages/container/{args.container}/versions/{sorted_versions[idx]['id']}")
            request.raise_for_status()
            print(f"Version with id={sorted_versions[idx]['id']} was deleted")
