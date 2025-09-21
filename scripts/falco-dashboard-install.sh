#!/usr/bin/env bash

kubectl -n monitoring create configmap grafana-dashboard-falco  --from-file=k8s/falco-dashboard.json
kubectl -n monitoring label configmap grafana-dashboard-falco  grafana_dashboard="1" release=monitoring --overwrite
