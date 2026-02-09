variable "namespaces" {
  description = "List of namespaces to create"
  type = list(object({
    name        = string
    labels      = map(string)
    annotations = map(string)
  }))
}