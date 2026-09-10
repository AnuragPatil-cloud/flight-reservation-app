# Monitoring stack

VM2 is the administration host. The monitoring stack should run inside the existing AKS cluster rather than consuming the VM's limited resources.

Recommended stack:
- kube-prometheus-stack: Prometheus + Grafana + Alertmanager + Kubernetes/node exporters
- Argo CD: GitOps deployment controller (already installed separately)

Install from VM2 after the application is healthy:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values monitoring/kube-prometheus-stack-values.yaml
```

This file does not alter the application's UI or business logic. Application-specific scraping can be added later if actuator/metrics endpoints are enabled in the Spring Boot services.
