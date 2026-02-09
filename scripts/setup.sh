#!/bin/bash

# Main setup script for DevOps reference project
set -e

echo "🚀 Setting up DevOps Reference Project..."

# Check prerequisites
check_prerequisites() {
    echo "📋 Checking prerequisites..."
    
    # Check for required tools
    for tool in kubectl docker helm; do
        if ! command -v $tool &> /dev/null; then
            echo "❌ $tool is not installed. Please install it first."
            exit 1
        else
            echo "✅ $tool is installed"
        fi
    done
    
    # Check if kubernetes cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    else
        echo "✅ Kubernetes cluster is accessible"
    fi
}

# Create namespaces
create_namespaces() {
    echo "📦 Creating namespaces..."
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace trivy-system --dry-run=client -o yaml | kubectl apply -f -
}

# Install Argo CD
install_argocd() {
    echo "🔄 Installing Argo CD..."
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl apply -f manifests/argocd/
}

# Install Prometheus
install_prometheus() {
    echo "📊 Installing Prometheus..."
    kubectl apply -f manifests/prometheus/
}

# Install Grafana
install_grafana() {
    echo "📈 Installing Grafana..."
    kubectl apply -f manifests/grafana/
}

# Install Trivy operator
install_trivy() {
    echo "🔒 Installing Trivy operator..."
    kubectl apply -f manifests/trivy/
}

# Build and deploy sample app
deploy_sample_app() {
    echo "🏗️ Building and deploying sample application..."
    cd apps/sample-app
    docker build -t sample-app:latest .
    cd ../..
    
    # For local clusters like kind/minikube, load the image
    if command -v kind &> /dev/null; then
        kind load docker-image sample-app:latest 2>/dev/null || true
    fi
    
    kubectl apply -f apps/sample-app/k8s/
}

# Wait for deployments
wait_for_deployments() {
    echo "⏳ Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
    kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring
}

# Show access information
show_access_info() {
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "📋 Access Information:"
    echo "======================"
    
    # Argo CD
    echo "Argo CD:"
    echo "- URL: $(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
    echo "- Username: admin"
    echo "- Password: $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d)"
    echo ""
    
    # Grafana
    echo "Grafana:"
    echo "- URL: http://$(kubectl get svc grafana-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):3000"
    echo "- Username: admin"
    echo "- Password: admin123"
    echo ""
    
    # Prometheus
    echo "Prometheus:"
    echo "- URL: http://$(kubectl get svc prometheus-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):9090"
    echo ""
}

# Main execution
main() {
    check_prerequisites
    create_namespaces
    install_argocd
    install_prometheus
    install_grafana
    install_trivy
    deploy_sample_app
    wait_for_deployments
    show_access_info
}

main "$@"