#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
JENKINS_NAMESPACE="jenkins"
JENKINS_MANIFESTS_DIR="../manifests/jenkins"
TIMEOUT=300

echo -e "${GREEN}🚀 Deploying Jenkins to Kubernetes...${NC}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

# Create namespace if it doesn't exist
kubectl create namespace ${JENKINS_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Apply manifests in order
echo -e "${YELLOW}🔧 Applying Jenkins manifests...${NC}"

# 1. Apply RBAC
echo "Applying RBAC..."
kubectl apply -f ${JENKINS_MANIFESTS_DIR}/rbac.yaml -n ${JENKINS_NAMESPACE}

# 2. Apply ConfigMap for Configuration as Code
echo "Applying Configuration as Code..."
kubectl apply -f ${JENKINS_MANIFESTS_DIR}/configmap.yaml -n ${JENKINS_NAMESPACE}

# 3. Apply PVC
echo "Applying Persistent Volume Claim..."
kubectl apply -f ${JENKINS_MANIFESTS_DIR}/pvc.yaml -n ${JENKINS_NAMESPACE}

# 4. Apply Deployment
echo "Applying Jenkins Deployment..."
kubectl apply -f ${JENKINS_MANIFESTS_DIR}/deployment.yaml -n ${JENKINS_NAMESPACE}

# 5. Apply Services
echo "Applying Jenkins Services..."
kubectl apply -f ${JENKINS_MANIFESTS_DIR}/service.yaml -n ${JENKINS_NAMESPACE}

# 6. Apply Ingress (optional)
if kubectl get ingressclass nginx &> /dev/null; then
    echo "Applying Ingress..."
    kubectl apply -f ${JENKINS_MANIFESTS_DIR}/ingress.yaml -n ${JENKINS_NAMESPACE}
else
    echo -e "${YELLOW}⚠️  NGINX Ingress Controller not found, skipping Ingress creation${NC}"
fi

echo -e "${YELLOW}⏳ Waiting for Jenkins to be ready...${NC}"

# Wait for deployment to be ready
kubectl wait --for=condition=available deployment/jenkins -n ${JENKINS_NAMESPACE} --timeout=${TIMEOUT}s

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=jenkins -n ${JENKINS_NAMESPACE} --timeout=${TIMEOUT}s

echo -e "${GREEN}✅ Jenkins deployed successfully!${NC}"

# Get access information
echo -e "${YELLOW}📊 Access Information:${NC}"

# Get service details
SERVICE_TYPE=$(kubectl get svc jenkins-service -n ${JENKINS_NAMESPACE} -o jsonpath='{.spec.type}')

if [ "$SERVICE_TYPE" = "LoadBalancer" ]; then
    # Get external IP for LoadBalancer
    EXTERNAL_IP=$(kubectl get svc jenkins-service -n ${JENKINS_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -z "$EXTERNAL_IP" ]; then
        EXTERNAL_IP=$(kubectl get svc jenkins-service -n ${JENKINS_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    fi
    echo -e "${GREEN}🌐 Jenkins URL: http://${EXTERNAL_IP}:8080${NC}"
elif kubectl get ingress jenkins-ingress -n ${JENKINS_NAMESPACE} &> /dev/null; then
    # Get ingress host
    INGRESS_HOST=$(kubectl get ingress jenkins-ingress -n ${JENKINS_NAMESPACE} -o jsonpath='{.spec.rules[0].host}')
    echo -e "${GREEN}🌐 Jenkins URL: http://${INGRESS_HOST}${NC}"
else
    # Use port forwarding
    echo -e "${GREEN}🔗 To access Jenkins via port forwarding:${NC}"
    echo -e "   kubectl port-forward svc/jenkins-service 8080:8080 -n ${JENKINS_NAMESPACE}"
    echo -e "${GREEN}🌐 Then open: http://localhost:8080${NC}"
fi

echo -e "${YELLOW}🔑 Default Credentials:${NC}"
echo -e "   Username: admin"
echo -e "   Password: admin123"

echo -e "${YELLOW}⚠️  IMPORTANT: Change the default password after first login!${NC}"

# Show pod status
echo -e "${YELLOW}📈 Jenkins Pod Status:${NC}"
kubectl get pods -n ${JENKINS_NAMESPACE} -l app.kubernetes.io/name=jenkins

echo -e "${GREEN}🎉 Jenkins deployment completed!${NC}"