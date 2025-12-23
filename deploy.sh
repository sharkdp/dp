#!/bin/bash

set -euo pipefail

rsync --archive --force --compress --progress --rsh="ssh" \
    index.html sitemap.xml css js files img shark@shark.fish:/var/www/html/david-peter.de/
