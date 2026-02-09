.PHONY: help setup deploy scan clean test lint terraform jenkins

help:
	@echo "DevOps Reference Project - Available Commands:"
	@echo "  setup     - Initialize the entire DevOps stack"
	@echo "  deploy    - Deploy applications via GitOps"
	@echo "  scan      - Run security scans"
	@echo "  test      - Run tests"
	@echo "  lint      - Run linting"
	@echo "  clean     - Clean up all resources"
	@echo ""
	@echo "Terraform Commands:"
	@echo "  terraform-init     - Initialize Terraform configuration"
	@echo "  terraform-plan      - Show Terraform execution plan"
	@echo "  terraform-apply     - Apply Terraform configuration"
	@echo "  terraform-destroy   - Destroy Terraform-managed infrastructure"
	@echo "  terraform-validate  - Validate Terraform configuration"
	@echo ""
	@echo "Jenkins Commands:"
	@echo "  jenkins-deploy      - Deploy Jenkins to Kubernetes"
	@echo "  jenkins-cleanup     - Clean up Jenkins deployment"
	@echo "  jenkins-access      - Show Jenkins access information"
	@echo ""
	@echo "CI/CD Options:"
	@echo "  github-actions      - Use GitHub Actions (default)"
	@echo "  jenkins-pipeline    - Use Jenkins pipeline"

setup:
	@echo "Setting up DevOps stack..."
	./scripts/setup.sh

deploy:
	@echo "Deploying applications..."
	./scripts/deploy.sh

scan:
	@echo "Running security scans..."
	./scripts/security-scan.sh

test:
	@echo "Running tests..."
	cd apps/sample-app && npm test

lint:
	@echo "Running linting..."
	cd apps/sample-app && npm run lint

clean:
	@echo "Cleaning up resources..."
	./scripts/destroy.sh

docker-build:
	@echo "Building Docker image..."
	docker build -t sample-app:latest apps/sample-app/

docker-run:
	@echo "Running sample application..."
	docker run -p 3000:3000 sample-app:latest

# Terraform commands
terraform-init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

terraform-plan:
	@echo "Planning Terraform changes..."
	cd terraform && terraform plan

terraform-apply:
	@echo "Applying Terraform configuration..."
	cd terraform && terraform apply -auto-approve

terraform-destroy:
	@echo "Destroying Terraform-managed infrastructure..."
	cd terraform && terraform destroy -auto-approve

terraform-validate:
	@echo "Validating Terraform configuration..."
	cd terraform && terraform validate

terraform-fmt:
	@echo "Formatting Terraform files..."
	cd terraform && terraform fmt -recursive

# Jenkins commands
jenkins-deploy:
	@echo "Deploying Jenkins to Kubernetes..."
	./scripts/jenkins/deploy-jenkins.sh

jenkins-cleanup:
	@echo "Cleaning up Jenkins deployment..."
	./scripts/jenkins/cleanup-jenkins.sh

jenkins-access:
	@echo "Getting Jenkins access information..."
	@echo "Jenkins Pod Status:"
	@kubectl get pods -n jenkins -l app.kubernetes.io/name=jenkins
	@echo ""
	@echo "Jenkins Service:"
	@kubectl get svc jenkins-service -n jenkins
	@echo ""
	@echo "To access via port forwarding:"
	@echo "  kubectl port-forward svc/jenkins-service 8080:8080 -n jenkins"
	@echo "  Then open: http://localhost:8080"
	@echo ""
	@echo "Default credentials: admin / admin123"

# CI/CD Pipeline commands
github-actions:
	@echo "GitHub Actions is the default CI/CD system"
	@echo "Configure in .github/workflows/ci-cd.yml"
	@echo "No additional setup required"

jenkins-pipeline:
	@echo "Using Jenkins for CI/CD pipeline"
	@echo "Ensure Jenkins is deployed: make jenkins-deploy"
	@echo "Pipeline definition: Jenkinsfile"
	@echo "Agent configuration: jenkins-agent.yaml"