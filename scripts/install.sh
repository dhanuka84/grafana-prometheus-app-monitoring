#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=monitoring
RELEASE=monitoring
CHART=prometheus-community/kube-prometheus-stack

kubectl apply -f k8s/namespace.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install "$RELEASE" "$CHART" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f values.yaml

kubectl rollout status deployment "$RELEASE-grafana" -n "$NAMESPACE" --timeout=5m || true
kubectl rollout status statefulset "$RELEASE-kube-prometheus-stack-prometheus" -n "$NAMESPACE" --timeout=5m || true

kubectl get svc -n "$NAMESPACE"
