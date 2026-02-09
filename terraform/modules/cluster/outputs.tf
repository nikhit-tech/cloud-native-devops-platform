output "cluster_name" {
  description = "Name of the created Kubernetes cluster"
  value       = data.external.cluster_info.result.name
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = data.external.cluster_info.result.endpoint
}

output "kube_config" {
  description = "Path to kubeconfig file"
  value       = var.kube_config_path
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = data.external.cluster_info.result.ca_cert
}

output "cluster_type" {
  description = "Type of cluster created"
  value       = var.cluster_type
}