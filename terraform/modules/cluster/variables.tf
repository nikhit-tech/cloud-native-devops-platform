variable "cluster_type" {
  description = "Type of Kubernetes cluster: kind, eks, gke, aks"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "kind_config_path" {
  description = "Path to Kind cluster configuration file"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider: aws, gcp, azure"
  type        = string
}

variable "region" {
  description = "Cloud provider region"
  type        = string
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

variable "kube_config_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

locals {
  is_kind_cluster = var.cluster_type == "kind"
  is_eks_cluster  = var.cluster_type == "eks"
  is_gke_cluster  = var.cluster_type == "gke"
  is_aks_cluster  = var.cluster_type == "aks"
}