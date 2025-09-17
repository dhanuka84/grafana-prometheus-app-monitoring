#!/usr/bin/env bash

kubectl -n monitoring create configmap grafana-dashboard-springboot-11378   --from-file=k8s/springboot-dashboard.json
kubectl -n monitoring label configmap grafana-dashboard-springboot-11378  grafana_dashboard="1" release=monitoring --overwrite
