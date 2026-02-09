output "namespaces" {
  description = "List of created namespaces"
  value = [
    for ns in kubernetes_namespace.namespaces : {
      name      = ns.metadata[0].name
      labels    = ns.metadata[0].labels
      namespace = ns.metadata[0].namespace
    }
  ]
}

output "namespace_names" {
  description = "List of namespace names"
  value = [
    for ns in kubernetes_namespace.namespaces : ns.metadata[0].name
  ]
}