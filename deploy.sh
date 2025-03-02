#!/bin/bash

set -euo pipefail

lessc --verbose css/main.less css/main.css

python -m csscompressor css/main.css > css/main.min.css
mv css/main.min.css css/main.css

rsync --archive --force --compress --progress --rsh="ssh" \
    index.html sitemap.xml css js files img shark@shark.fish:/var/www/html/david-peter.de/
