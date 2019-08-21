#!/bin/sh
# 
# This builds and serves using Hugo, but avoids watching for changes as this requires too many open files:
hugo serve --watch=false
