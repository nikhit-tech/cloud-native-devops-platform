#!/bin/bash

# Cleanup script
set -e

echo "🧹 Cleaning up DevOps Reference Project..."

# Delete Argo CD applications
echo "📦 Deleting Argo CD applications..."
kubectl delete application sample-app -n argocd --ignore-not-found=true

# Delete installed components
echo "🗑️ Removing installed components..."
kubectl delete -f manifests/trivy/ --ignore-not-found=true
kubectl delete -f manifests/grafana/ --ignore-not-found=true
kubectl delete -f manifests/prometheus/ --ignore-not-found=true
kubectl delete -f manifests/argocd/ --ignore-not-found=true

# Uninstall Argo CD
kubectl delete namespace argocd --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true
kubectl delete namespace trivy-system --ignore-not-found=true

# Delete sample app
kubectl delete -f apps/sample-app/k8s/ --ignore-not-found=true

echo "✅ Cleanup completed!"