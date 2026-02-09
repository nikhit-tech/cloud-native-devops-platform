# Cluster Configuration
variable "cluster_type" {
  description = "Type of Kubernetes cluster: kind, eks, gke, aks"
  type        = string
  default     = "kind"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "devops-ref"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.0"
}

# Kind Cluster Variables
variable "kind_config_path" {
  description = "Path to Kind cluster configuration file"
  type        = string
  default     = "./config/kind-config.yaml"
}

# Managed Cluster Variables
variable "cloud_provider" {
  description = "Cloud provider: aws, gcp, azure"
  type        = string
  default     = "aws"
}

variable "region" {
  description = "Cloud provider region"
  type        = string
  default     = "us-west-2"
}

variable "node_count" {
  description = "Number of worker nodes for managed clusters"
  type        = number
  default     = 3
}

variable "node_type" {
  description = "Instance type for managed clusters"
  type        = string
  default     = "t3.medium"
}

# Kubernetes Provider Variables
variable "kube_config_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubernetes_host" {
  description = "Kubernetes API server host"
  type        = string
  default     = ""
}

variable "kubernetes_token" {
  description = "Kubernetes authentication token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "kubernetes_ca_cert" {
  description = "Kubernetes CA certificate"
  type        = string
  default     = ""
  sensitive   = true
}

# Namespaces Configuration
variable "namespaces" {
  description = "List of namespaces to create"
  type = list(object({
    name        = string
    labels      = map(string)
    annotations = map(string)
  }))
  default = [
    {
      name        = "argocd"
      labels      = { "app.kubernetes.io/part-of" = "argocd" }
      annotations = {}
    },
    {
      name        = "monitoring"
      labels      = { "app.kubernetes.io/part-of" = "monitoring" }
      annotations = {}
    },
    {
      name        = "jenkins"
      labels      = { "app.kubernetes.io/part-of" = "jenkins" }
      annotations = {}
    }
  ]
}

# Terraform State Configuration
variable "state_backend" {
  description = "Type of state backend: local, s3, gcs, azurerm"
  type        = string
  default     = "local"
}

variable "state_bucket" {
  description = "S3/GCS bucket name for remote state"
  type        = string
  default     = ""
}

variable "state_region" {
  description = "Region for remote state storage"
  type        = string
  default     = "us-west-2"
}