resource "kubernetes_secret" "docker_secret" {
  count = local.namespace_resources
  metadata {
    name      = "docker-cfg"
    namespace = local.namespace
  }

  data = {
    ".dockerconfigjson" = data.terraform_remote_state.docker_config.outputs.docker_config
  }

  type = "kubernetes.io/dockerconfigjson"
}


locals {
  docker_secret = local.manage_namespace ? kubernetes_secret.docker_secret.0.metadata.0.name : "docker-cfg"
}
