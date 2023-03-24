#!/bin/bash
NUMBER=$(date +"%d%H%M")

act --workflows .github/workflows/terraform/main_cd_dev.yml -s GITHUB_TOKEN=$1 --input js_image_dev=$2 --input wp_image_dev=$3 --input namespace_extended_number=$NUMBER

act --workflows .github/workflows/terraform/main_cd_prod.yml -s GITHUB_TOKEN=$1 --input js_image_prod=$4 --input wp_image_prod=$5 --input namespace_extended_number=$NUMBER
