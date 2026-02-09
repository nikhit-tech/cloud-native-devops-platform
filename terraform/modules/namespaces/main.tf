# Create namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each = { for ns in var.namespaces : ns.name => ns }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }
}

# Create NetworkPolicy for each namespace (default deny all)
resource "kubernetes_network_policy" "default_deny" {
  for_each = { for ns in var.namespaces : ns.name => ns }

  metadata {
    name      = "${each.value.name}-default-deny"
    namespace = each.value.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

# Allow DNS resolution
resource "kubernetes_network_policy" "allow_dns" {
  for_each = { for ns in var.namespaces : ns.name => ns }

  metadata {
    name      = "${each.value.name}-allow-dns"
    namespace = each.value.name
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]

    egress {
      to {
        pod_selector {}
      }
      ports {
        protocol = "UDP"
        port     = "53"
      }
    }

    egress {
      to {
        namespace_selector {}
      }
      ports {
        protocol = "TCP"
        port     = "53"
      }
    }
  }
}