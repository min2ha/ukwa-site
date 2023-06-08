#!/bin/sh
docker run --rm -it \
  -v $(pwd):/src \
  -p 1313:1313 \
  klakegg/hugo:latest-ext \
  server --watch=false -v
# Built at 11:54 after 181s, still hanging at 12:00. Killing. 