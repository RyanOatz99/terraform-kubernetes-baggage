resource "kubernetes_secret" "docker_secret" {
  metadata {
    name      = "docker-cfg"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = var.docker_config
  }

  type = "kubernetes.io/dockerconfigjson"
}
