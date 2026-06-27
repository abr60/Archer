#!/usr/bin/env bash

# 1. Get the exact folder where this script lives
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Run the scripts in order using the local path
source "$DIR/system-services.sh"
source "$DIR/user-services.sh"
source "$DIR/reload.sh"
