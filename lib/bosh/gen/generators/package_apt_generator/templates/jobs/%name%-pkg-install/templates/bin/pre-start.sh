#!/bin/bash

set -x
cd /var/vcap/packages/<%= name %>/apt/cache/archives
. install-packages.sh
