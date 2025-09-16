# Monitoring Sample Project (Minikube + Prometheus + Grafana + Spring Boot)

This project demonstrates how to set up Prometheus and Grafana monitoring on **Minikube**
using the `kube-prometheus-stack` Helm chart, and how to scrape metrics from a sample
Spring Boot application exposing Micrometer Prometheus metrics.

---

## Contents

- `k8s/` → Kubernetes manifests (namespaces, app deployment, service, ServiceMonitor)
- `scripts/` → Helper scripts to start Minikube, install monitoring stack, port-forward, uninstall
- `app/` → Sample Spring Boot app with Micrometer + Prometheus

---

## Quick Start

### 1) Start Minikube
```bash
./scripts/start-minikube.sh
```

### 2) Install monitoring stack (Prometheus + Grafana)
```bash
./scripts/install.sh
```

### 3.a) Build and deploy sample app
```bash
mvn -U -DskipTests clean package
minikube image build -t demo-metrics:latest ./app
kubectl apply -f k8s/apps-namespace.yaml
kubectl apply -f k8s/demo-deployment.yaml
kubectl apply -f k8s/demo-service.yaml
kubectl apply -f k8s/servicemonitor-demo.yaml
```
### 3.b) Rebuild and Build and deploy sample app
```bash
cd ..   # repo root with Dockerfile in app/
minikube image build -t demo-metrics:latest ./app

kubectl -n apps rollout restart deploy/demo-metrics
kubectl -n apps logs -l app=demo-metrics -f
```

### 4) Access Grafana
```bash
minikube service -n monitoring monitoring-grafana --url
# login: admin / admin123
```

### 5) Verify metrics in Prometheus
```bash
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090
# open http://localhost:9090 → Status → Targets
```

### 6) Testing App metrics
```bash
$ kubectl -n apps port-forward svc/demo-metrics 8080:8080
$ curl -s http://localhost:8080/actuator/prometheus | head -20
```
``` output

# HELP application_ready_time_seconds Time taken for the application to be ready to service requests
# TYPE application_ready_time_seconds gauge
application_ready_time_seconds{main_application_class="dev.sample.DemoApplication"} 2.522
# HELP application_started_time_seconds Time taken to start the application
# TYPE application_started_time_seconds gauge
application_started_time_seconds{main_application_class="dev.sample.DemoApplication"} 2.435
# HELP disk_free_bytes Usable space for path
# TYPE disk_free_bytes gauge
disk_free_bytes{path="/app/."} 3.9842306048E11
# HELP disk_total_bytes Total space for path
# TYPE disk_total_bytes gauge
disk_total_bytes{path="/app/."} 7.80912443392E11
# HELP executor_active_threads The approximate number of threads that are actively executing tasks
# TYPE executor_active_threads gauge
executor_active_threads{name="applicationTaskExecutor"} 0.0
# HELP executor_completed_tasks_total The approximate total number of tasks that have completed execution
# TYPE executor_completed_tasks_total counter
executor_completed_tasks_total{name="applicationTaskExecutor"} 0.0
# HELP executor_pool_core_threads The core number of threads for the pool
# TYPE executor_pool_core_threads gauge
```

---

## Cleanup
```bash
./scripts/uninstall.sh
minikube delete
```

---

## Next Steps
- Import dashboards for Spring Boot / Micrometer in Grafana
- Add Alertmanager routes (Slack, Webhook)
- Explore custom metrics and HPA demos

---
