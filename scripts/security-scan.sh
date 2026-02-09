#!/bin/bash

# Security scanning script
set -e

echo "🔒 Running security scans..."

# Container scan
echo "📦 Scanning container images..."
./scripts/trivy-container-scan.sh sample-app:latest

# IaC scan
echo "🏗️ Scanning Infrastructure as Code..."
./scripts/trivy-iac-scan.sh

echo "✅ Security scans completed!"
echo "📊 Check the security-reports directory for detailed results"