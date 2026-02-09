# Kubernetes Cluster Information
output "cluster_name" {
  description = "Name of the created Kubernetes cluster"
  value       = module.k8s_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = module.k8s_cluster.cluster_endpoint
  sensitive   = true
}

output "kube_config" {
  description = "Path to kubeconfig file"
  value       = module.k8s_cluster.kube_config
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = module.k8s_cluster.cluster_ca_certificate
  sensitive   = true
}

# Namespaces Information
output "created_namespaces" {
  description = "List of created namespaces"
  value       = module.namespaces.namespaces
}

# Access Information
output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = "argocd"
}

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = "monitoring"
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = "jenkins"
}