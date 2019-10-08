resource "kubernetes_service" "baggage" {
  metadata {
    name = var.set_name
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name" = var.set_name
      "app.kubernetes.io/part-of" = "baggage"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = var.set_name
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
