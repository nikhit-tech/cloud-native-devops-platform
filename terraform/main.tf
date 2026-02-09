terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }

  # Remote state configuration - using local file for demo, but can be configured for remote backends
  backend "local" {
    path = "./terraform.tfstate"
  }

  # Uncomment for production remote backends:
  # backend "s3" {
  #   bucket         = "devops-ref-terraform-state"
  #   key            = "terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

# Configure Kubernetes provider
provider "kubernetes" {
  config_path = var.kube_config_path
  host        = var.kubernetes_host
  token       = var.kubernetes_token
  ca_cert     = var.kubernetes_ca_cert
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
    host        = var.kubernetes_host
    token       = var.kubernetes_token
    ca_cert     = var.kubernetes_ca_cert
  }
}

# Kubernetes cluster module
module "k8s_cluster" {
  source = "./modules/cluster"

  cluster_type       = var.cluster_type
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Kind cluster specific
  kind_config_path = var.kind_config_path

  # Managed cluster specific
  cloud_provider = var.cloud_provider
  region         = var.region
  node_count     = var.node_count
  node_type      = var.node_type

  depends_on = []
}

# Namespaces module
module "namespaces" {
  source = "./modules/namespaces"

  namespaces = var.namespaces

  depends_on = [module.k8s_cluster]
}