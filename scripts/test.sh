#!/bin/bash
# build script that is ran from Teamcity pipeline

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -n "$TEAMCITY_VERSION" ]]; then
    # Try to run nomad-pack dependency vendoring
    cd "$BASE_DIR/packs/lume_release"
    nomad-pack deps vendor
else
    echo "This script should be run from Teamcity CI/CD pipeline"
    exit 1
fi
