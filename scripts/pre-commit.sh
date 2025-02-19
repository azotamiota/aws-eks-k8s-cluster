#!/bin/bash
# set -eo pipefail

apt-get update && apt-get install -y pre-commit
pre-commit run --all-files
