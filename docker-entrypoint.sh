#!/bin/bash
# WF 2015-10-18
# Mediawiki docker image entrypoint script
# 
set -e
echo "Preparing Mediawiki docker image"
service apache2 start
exec "$@"
