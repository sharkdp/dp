#!/bin/bash

lessc --verbose css/main.less css/main.css

yuicompressor css/main.css > css/main.min.css
mv css/main.min.css css/main.css

closure-compiler js/zepto.min.js js/hyphenate.js js/main.js > js/main.min.js

rsync --archive --force --compress --progress --rsh="ssh" \
    index.html css js files img shark@kalyke.de:/var/www/html/david-peter.de/
