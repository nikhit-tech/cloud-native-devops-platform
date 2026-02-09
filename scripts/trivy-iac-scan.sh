#!/bin/bash

# Trivy IaC scanning script
set -e

REPORT_DIR="./security-reports"

echo "🏗️ Running Trivy IaC scan"

mkdir -p "$REPORT_DIR"

# IaC scan for Kubernetes manifests
echo "Scanning Kubernetes manifests..."
find . -name "*.yaml" -o -name "*.yml" | \
  trivy config --format json --output "$REPORT_DIR/iac-scan.json" -f

# IaC scan (human readable)
find . -name "*.yaml" -o -name "*.yml" | \
  trivy config --severity HIGH,CRITICAL

# Generate SARIF for GitHub Security tab
find . -name "*.yaml" -o -name "*.yml" | \
  trivy config --format sarif --output "$REPORT_DIR/iac-scan.sarif" -f

echo "✅ IaC scan completed. Reports saved to $REPORT_DIR"