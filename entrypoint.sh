#!/bin/sh
# entrypoint.sh

set -e

cmd="$@"

# Install dependencies
if [ -e package.json ]; then
  yarn install
fi

exec $cmd