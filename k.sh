#!/usr/bin/env bash
set -euo pipefail
export AWS_PROFILE=ec2admin
export AWS_REGION=us-east-2
export AWS_DEFAULT_REGION=us-east-2
kubectl "$@"
