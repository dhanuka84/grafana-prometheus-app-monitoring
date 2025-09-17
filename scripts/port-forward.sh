#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=monitoring
RELEASE=monitoring

kubectl -n "$NAMESPACE" port-forward svc/$RELEASE-grafana 3000:80 &
kubectl -n "$NAMESPACE" port-forward svc/$RELEASE-kube-prometheus-prometheus 9090:9090 &

wait
