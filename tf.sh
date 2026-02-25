#!/usr/bin/env bash
set -euo pipefail
export AWS_PROFILE=infra
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1
terraform "$@"
