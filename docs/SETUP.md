# Setup Guide

This document provides detailed setup instructions for the DevOps reference project.

## Prerequisites

### System Requirements
- **OS**: Linux, macOS, or Windows with WSL2
- **Memory**: Minimum 8GB RAM (16GB recommended)
- **Storage**: 10GB free disk space

### Required Tools
```bash
# Core tools
kubectl v1.25+          # Kubernetes CLI
docker v20.10+          # Container runtime
helm v3.12+             # Kubernetes package manager
git v2.30+              # Version control

# Infrastructure as Code
terraform >=1.5.0       # Infrastructure provisioning
kind v0.20+             # Local Kubernetes cluster

# CI/CD & GitOps
argocd v2.8.0+          # Argo CD CLI
trivy v0.45.0+          # Security scanner

# Optional
make                     # Build automation (most systems have this)
```

### Tool Installation

#### macOS
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install kubectl docker helm terraform kind trivy argocd
```

#### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo install linux-amd64/helm /usr/local/bin/helm

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install Trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install trivy

# Install Argo CD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
```

## Project Setup

### 1. Clone and Configure
```bash
# Clone the repository
git clone https://github.com/__YOUR_ORG__/devops-reference-project.git
cd devops-reference-project

# Configure environment variables
cp .env.example .env
# Edit .env with your values
```

### 2. Choose Your Setup Approach

#### Option A: Complete Terraform Setup (Recommended)
```bash
# For local development
export TF_VAR_cluster_type="kind"

# Initialize Terraform
make terraform-init

# Plan and apply infrastructure
make terraform-plan
make terraform-apply
```

#### Option B: Quick Start with Manual Cluster
```bash
# Create Kind cluster manually
kind create cluster --name devops-ref

# Verify cluster
kubectl cluster-info
```

### 3. Deploy DevOps Stack
```bash
# Automated setup of all components
make setup

# Or run manually
./scripts/setup.sh
```

## Component Setup Details

### Argo CD Setup
```bash
# Deploy Argo CD
kubectl apply -f manifests/argocd/

# Wait for Argo CD to be ready
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get Argo CD password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d
```

### Jenkins Setup (Optional)
```bash
# Deploy Jenkins
kubectl apply -f manifests/jenkins/

# Wait for Jenkins to be ready
kubectl wait --for=condition=available deployment/jenkins -n jenkins --timeout=300s

# Get Jenkins access
kubectl port-forward svc/jenkins-service 8080:8080 -n jenkins
# Username: admin, Password: admin123
```

### Monitoring Setup
```bash
# Deploy monitoring stack
kubectl apply -f manifests/prometheus/
kubectl apply -f manifests/grafana/

# Verify monitoring components
kubectl get pods -n monitoring
```

## Configuration

### Environment Variables
Create `.env` file with your configuration:
```bash
# GitHub organization/repository
GITHUB_ORG=your-org
GITHUB_REPO=devops-reference-project

# Container registry
CONTAINER_REGISTRY=ghcr.io
IMAGE_NAMESPACE=${GITHUB_ORG}

# Application configuration
APP_NAME=sample-app
APP_NAMESPACE=applications
```

### GitHub Actions Configuration
Set up GitHub Secrets:
- `DOCKER_REGISTRY`: Container registry URL
- `KUBE_CONFIG`: Base64-encoded kubeconfig
- `ARGOCD_SERVER`: Argo CD server URL
- `ARGOCD_USERNAME`: Argo CD username
- `ARGOCD_PASSWORD`: Argo CD password

## Verification

### Health Checks
```bash
# Check all deployments
kubectl get deployments -A

# Check pod status
kubectl get pods -A

# Check services
kubectl get svc -A

# Test sample application
kubectl port-forward svc/sample-app-service 8080:80
curl http://localhost:8080/health
```

### Component Access
```bash
# Argo CD
kubectl port-forward svc/argocd-server 8080:443 -n argocd
# URL: https://localhost:8080

# Grafana (port 3010 to avoid conflicts)
kubectl port-forward svc/grafana-service 3010:3000 -n monitoring
# URL: http://localhost:3010

# Prometheus
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
# URL: http://localhost:9090

# Jenkins (if deployed)
kubectl port-forward svc/jenkins-service 8080:8080 -n jenkins
# URL: http://localhost:8080
```

## Common Setup Issues

### Permission Issues
```bash
# Fix Docker permissions (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Fix kubectl permissions
mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

### Network Issues
```bash
# Check cluster networking
kubectl get pods -A -o wide

# Check service endpoints
kubectl get endpoints -A

# Test connectivity
kubectl run test-pod --image=busybox --rm -it -- /bin/sh
# Inside pod: nslookup kubernetes.default
```

### Resource Issues
```bash
# Check node resources
kubectl describe nodes

# Check resource usage
kubectl top nodes
kubectl top pods -A
```