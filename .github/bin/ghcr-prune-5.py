#!/usr/bin/python3
# PYTHON_ARGCOMPLETE_OK
import argparse
import dateutil.parser
import getpass
import os
import requests
import numpy
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

    # Добавление индекса и даты образов в массив
    for index, v in enumerate(versions):
        created = v["created_at"]
        metadata = v["metadata"]["container"]
        array_of_index_and_datetime_creation.insert(0,created)
        array_of_index_and_datetime_creation.insert(0,v["id"])

    # Создание массива как объект из индекса и даты создания для каждого образа отдельно
    arr_buf = numpy.array(array_of_index_and_datetime_creation)
    unsorted_array_of_index_and_datetime_creation = numpy.array_split(arr_buf,len(versions))

    # Соритировка по дате
    sorted_array_of_index_and_datetime_creation = sorted(unsorted_array_of_index_and_datetime_creation, key=lambda x: x[1], reverse=True)
    print(sorted_array_of_index_and_datetime_creation)

    # Массив для "удаляемых" образов
    delete_sorted_array_of_index_and_datetime_creation = []

    # Проверка на то, есть ли образы, необходимые для удаления. Если есть, то они добавляются в массив
    if len(sorted_array_of_index_and_datetime_creation) > 0 and len(sorted_array_of_index_and_datetime_creation)>args.number:
        for i in range(len(sorted_array_of_index_and_datetime_creation)-args.number):
            delete_sorted_array_of_index_and_datetime_creation.extend(sorted_array_of_index_and_datetime_creation[i+args.number])

    # len/2: массивы как объекты из двух значений: id,date, при делении на 2 получаются такие спаренные объекты-массивы из длины всего большого массива
    if len(sorted_array_of_index_and_datetime_creation) > 0 and len(sorted_array_of_index_and_datetime_creation)>args.number:
        delete_sorted_array_of_index_and_datetime_creation = numpy.array_split(delete_sorted_array_of_index_and_datetime_creation,len(delete_sorted_array_of_index_and_datetime_creation)/2)

    # Удаление всех образов из массива "удаляемых" образов
    if len(sorted_array_of_index_and_datetime_creation) > 0 and len(sorted_array_of_index_and_datetime_creation)>args.number:
        for index, v in enumerate(delete_sorted_array_of_index_and_datetime_creation):
            if args.dry_run:
                print(f'would delete {v[0]}')
            else:
                r = s.delete(f'https://api.github.com/user/packages/'
                            f'container/{args.container}/versions/{v[0]}')
                r.raise_for_status()
                print(f'deleted {v[0]}')
