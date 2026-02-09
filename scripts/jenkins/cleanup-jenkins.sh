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

echo -e "${GREEN}🧹 Cleaning up Jenkins deployment...${NC}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace ${JENKINS_NAMESPACE} &> /dev/null; then
    echo -e "${YELLOW}⚠️  Namespace ${JENKINS_NAMESPACE} does not exist${NC}"
    exit 0
fi

echo -e "${YELLOW}🗑️  Removing Jenkins resources...${NC}"

# Remove resources in reverse order
if kubectl get ingress jenkins-ingress -n ${JENKINS_NAMESPACE} &> /dev/null; then
    echo "Removing Ingress..."
    kubectl delete ingress jenkins-ingress -n ${JENKINS_NAMESPACE}
fi

if kubectl get service jenkins-service -n ${JENKINS_NAMESPACE} &> /dev/null; then
    echo "Removing Services..."
    kubectl delete service jenkins-service -n ${JENKINS_NAMESPACE}
fi

if kubectl get service jenkins-agent -n ${JENKINS_NAMESPACE} &> /dev/null; then
    kubectl delete service jenkins-agent -n ${JENKINS_NAMESPACE}
fi

if kubectl get deployment jenkins -n ${JENKINS_NAMESPACE} &> /dev/null; then
    echo "Removing Deployment..."
    kubectl delete deployment jenkins -n ${JENKINS_NAMESPACE}
fi

if kubectl get pvc jenkins-pvc -n ${JENKINS_NAMESPACE} &> /dev/null; then
    echo "Removing Persistent Volume Claim..."
    kubectl delete pvc jenkins-pvc -n ${JENKINS_NAMESPACE}
fi

if kubectl get configmap jenkins-configuration-as-code -n ${JENKINS_NAMESPACE} &> /dev/null; then
    echo "Removing ConfigMaps..."
    kubectl delete configmap jenkins-configuration-as-code -n ${JENKINS_NAMESPACE}
fi

if kubectl get clusterrolebinding jenkins-cluster-role-binding &> /dev/null; then
    echo "Removing RBAC..."
    kubectl delete clusterrolebinding jenkins-cluster-role-binding
fi

if kubectl get clusterrole jenkins-cluster-role &> /dev/null; then
    kubectl delete clusterrole jenkins-cluster-role
fi

if kubectl get serviceaccount jenkins -n ${JENKINS_NAMESPACE} &> /dev/null; then
    kubectl delete serviceaccount jenkins -n ${JENKINS_NAMESPACE}
fi

# Remove namespace
echo "Removing namespace..."
kubectl delete namespace ${JENKINS_NAMESPACE}

echo -e "${GREEN}✅ Jenkins cleanup completed!${NC}"