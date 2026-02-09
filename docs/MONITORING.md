# Monitoring and Observability

This document covers the monitoring and observability setup in the DevOps reference project.

## Architecture Overview

The monitoring stack consists of:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Data visualization and dashboards
- **Sample App Metrics**: Custom application metrics

## Prometheus Configuration

### Deployment Configuration
Located in `manifests/prometheus/`:
- `deployment.yaml`: Prometheus deployment
- `configmap.yaml`: Prometheus configuration
- `service.yaml`: Prometheus service

### Key Features
- Scrapes application metrics from `/metrics` endpoint
- Self-monitoring with internal metrics
- Persistent storage for metrics data
- Service discovery for Kubernetes targets

### Configuration Details
```yaml
# Prometheus scraping configuration
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
```

## Grafana Configuration

### Deployment Configuration
Located in `manifests/grafana/`:
- `deployment.yaml`: Grafana deployment
- `service.yaml`: Grafana service (port 3010)
- `configmap.yaml`: Prometheus datasource configuration
- `dashboard-provider.yaml`: Dashboard provider configuration

### Default Credentials
- Username: `admin`
- Password: `admin123`

### Dashboard Configuration
- Pre-configured Prometheus datasource
- Auto-discovery of dashboard files
- Sample application dashboards

## Application Metrics

The sample application includes custom Prometheus metrics:

### HTTP Request Metrics
```javascript
// Request duration histogram
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

// Request counter
const httpRequestTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});
```

### Available Endpoints
- `/metrics`: Prometheus metrics endpoint
- `/health`: Health check endpoint
- `/`: Application endpoint with metrics collection

## Access Information

### Prometheus Access
```bash
# Port forward
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring

# Access in browser
open http://localhost:9090

# Check targets
curl http://localhost:9090/api/v1/targets
```

### Grafana Access
```bash
# Port forward
kubectl port-forward svc/grafana-service 3010:3000 -n monitoring

# Access in browser
open http://localhost:3010
# Username: admin / Password: admin123
```

## Monitoring Verification

### Check Component Status
```bash
# Verify Prometheus is running
kubectl get pods -n monitoring -l app=prometheus

# Verify Grafana is running
kubectl get pods -n monitoring -l app=grafana

# Check service endpoints
kubectl get endpoints -n monitoring
```

### Verify Metrics Collection
```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring &
curl http://localhost:9090/api/v1/targets

# Check application metrics
kubectl port-forward svc/sample-app-service 8080:80 &
curl http://localhost:8080/metrics
```

## Troubleshooting Monitoring Issues

### Prometheus Not Scraping Metrics
```bash
# Check Prometheus configuration
kubectl get configmap prometheus-config -n monitoring -o yaml

# Check Prometheus logs
kubectl logs deployment/prometheus -n monitoring

# Verify target endpoints
curl http://<target-service>:<port>/metrics
```

### Grafana Not Connecting to Prometheus
```bash
# Check datasource configuration
kubectl get configmap grafana-datasources -n monitoring -o yaml

# Check Grafana logs
kubectl logs deployment/grafana -n monitoring

# Verify Prometheus is accessible from Grafana
kubectl exec -it deployment/grafana -n monitoring -- wget -qO- http://prometheus-service:9090/api/v1/targets
```

## Scaling and Performance

### Resource Requirements
```yaml
# Prometheus resource requests
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"

# Grafana resource requests  
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Storage Considerations
- Prometheus metrics storage: 2Gi persistent volume
- Consider retention policies for long-term storage
- Monitor disk usage and implement cleanup policies

## Best Practices

### Monitoring Best Practices
- Use appropriate metric types (Counter, Histogram, Gauge)
- Include meaningful labels for filtering
- Set up alerting for critical metrics
- Regular monitoring of monitoring stack itself

### Grafana Best Practices
- Organize dashboards by team/service
- Use consistent naming conventions
- Implement panel templates for reusability
- Set up dashboard permissions

### Performance Optimization
- Adjust scrape intervals based on requirements
- Use recording rules for expensive queries
- Implement metric retention policies
- Monitor resource usage of monitoring components