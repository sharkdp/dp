#!/bin/bash

set -euo pipefail

rsync --archive --force --compress --progress --rsh="ssh" \
    --exclude 'collection.json' \
    index.html sitemap.xml css js files img lists articles shark@shark.fish:/var/www/html/david-peter.de/
