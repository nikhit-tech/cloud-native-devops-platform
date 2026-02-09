#!/bin/bash

# Deploy all applications using Argo CD
set -e

echo "🚀 Deploying applications via GitOps..."

# Create Argo CD application for sample app
kubectl apply -f manifests/argocd/sample-app.yaml

# Sync the application
argocd app sync sample-app

echo "✅ Applications deployed successfully!"
echo "📊 Check Argo CD UI for deployment status"