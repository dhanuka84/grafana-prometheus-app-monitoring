# From repo root
# 1) Build and load image into Minikube's Docker daemon
minikube image build -t demo-metrics:latest ./app


# 2) Create namespaces and deploy app
kubectl apply -f k8s/apps-namespace.yaml
kubectl apply -f k8s/demo-deployment.yaml
kubectl apply -f k8s/demo-service.yaml


# 3) Create ServiceMonitor in monitoring namespace
kubectl apply -f k8s/servicemonitor-demo.yaml


# 4) Check targets
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 &
# Open Prometheus → Status → Targets and confirm 'demo-metrics' is UP


# 5) Hit the app a bit to generate traffic/metrics
kubectl -n apps port-forward deploy/demo-metrics 8080:8080 &
curl -s http://localhost:8080/hello > /dev/null
curl -s http://localhost:8080/actuator/metrics/jvm.memory.used | jq . > /dev/null || true