#!/bin/bash
lastbackupfile=$(docker exec -t wp_db_js_app_dev pwd)
filename=$(printf $lastbackupfile | tr -d '\r')
echo "export const port = 8001;" > client/hooks/vars.js
docker cp client/hooks/vars.js wp_db_js_app_dev:$filename/hooks
