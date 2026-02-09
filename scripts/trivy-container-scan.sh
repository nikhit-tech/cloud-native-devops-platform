#!/bin/bash

# Trivy container scanning script
set -e

IMAGE_NAME=${1:-"sample-app:latest"}
REPORT_DIR="./security-reports"

echo "🔍 Running Trivy container scan for $IMAGE_NAME"

mkdir -p "$REPORT_DIR"

# Container vulnerability scan
echo "Scanning container vulnerabilities..."
trivy image --format json --output "$REPORT_DIR/container-scan.json" "$IMAGE_NAME"

# Container vulnerability scan (human readable)
trivy image --severity HIGH,CRITICAL "$IMAGE_NAME"

# Generate SARIF for GitHub Security tab
trivy image --format sarif --output "$REPORT_DIR/container-scan.sarif" "$IMAGE_NAME"

echo "✅ Container scan completed. Reports saved to $REPORT_DIR"