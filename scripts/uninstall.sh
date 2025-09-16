#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=monitoring
RELEASE=monitoring

helm uninstall "$RELEASE" -n "$NAMESPACE" || true
kubectl delete ns "$NAMESPACE" || true
