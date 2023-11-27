#!/bin/bash

set -Eeuo pipefail

ansible-galaxy collection install community.general
ansible-playbook configure.yaml

exit 0