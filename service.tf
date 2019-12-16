resource "kubernetes_service" "baggage" {
  metadata {
    name      = local.instance_name
    namespace = local.namespace

    labels = {
      "app.kubernetes.io/name"    = local.instance_name
      "app.kubernetes.io/part-of" = "baggage"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"    = local.instance_name
      "app.kubernetes.io/part-of" = "baggage"
    }

    port {
      port        = var.ingress_port
      target_port = "9292"
      name        = "baggage"
    }

    type = "NodePort"
  }
}
