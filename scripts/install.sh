#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=monitoring
RELEASE=monitoring
CHART=prometheus-community/kube-prometheus-stack

kubectl apply -f k8s/namespace.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

#install grafana and prometheus
helm upgrade --install "$RELEASE" "$CHART" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f grafana-values.yaml

#install loki

helm upgrade --install loki grafana/loki \
  -n monitoring \
  -f loki-values.yaml \
  --set loki.useTestSchema=true \
  --reset-values

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: loki-datasource
  namespace: monitoring
  labels:
    grafana_datasource: "1"
    release: monitoring        # <-- must match your kube-prometheus-stack release label
data:
  loki.yaml: |
    apiVersion: 1
    datasources:
      - name: Loki
        type: loki
        access: proxy
        url: http://loki.monitoring.svc.cluster.local:3100
        isDefault: false
        jsonData:
          maxLines: 1000
YAML

kubectl rollout status deployment "$RELEASE-grafana" -n "$NAMESPACE" --timeout=5m || true
kubectl rollout status statefulset "$RELEASE-kube-prometheus-stack-prometheus" -n "$NAMESPACE" --timeout=5m || true

kubectl get svc -n "$NAMESPACE"
