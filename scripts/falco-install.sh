#!/usr/bin/env bash
set -euo pipefail

# --- repos ---
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# --- namespaces ---
kubectl create ns falco || true
kubectl create ns monitoring || true

# --- values for Falco ---
cat > falco-values.yaml <<'YAML'
driver:
  kind: modern_ebpf

falco:
  jsonOutput: true
  programOutput:
    enabled: false   # optional; disable extra sidecar noise for now
YAML

# --- install Falco (DaemonSet) ---
helm upgrade --install falco falcosecurity/falco \
  --namespace falco \
  -f falco-values.yaml

# --- expose Falco metrics to Prometheus ---
helm upgrade --install falco-exporter falcosecurity/falco-exporter \
  --namespace monitoring \
  --set serviceMonitor.enabled=true \
  --set prometheusRules.enabled=true

# --- sanity checks ---
kubectl -n falco get pods -o wide
kubectl -n falco logs deploy/falco --tail=50 || true
