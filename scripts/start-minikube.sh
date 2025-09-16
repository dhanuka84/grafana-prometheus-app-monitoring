#!/usr/bin/env bash
set -euo pipefail

minikube start \
  --cpus=4 \
  --memory=6144 \
  --disk-size=20g \
  --kubernetes-version=stable \
  --driver=docker

minikube addons enable metrics-server || true
