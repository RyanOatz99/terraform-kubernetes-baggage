resource "kubernetes_ingress" "baggage_ingress" {
  metadata {
    name = var.set_name
    namespace = kubernetes_namespace.namespace.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.baggage_ingress.name
      "ingress.gcp.kubernetes.io/pre-shared-cert" = google_compute_managed_ssl_certificate.ssl.name
    }
  }

  spec {
    backend {
      service_name = kubernetes_service.baggage.metadata.0.name
      service_port = var.ingress_port
    }

    rule {
      host = "baggage-${var.environment}-wk.${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}"
      http {
        path {
          path = "/${var.environment}.${var.client_name}.prints/*"

          backend {
            service_name = kubernetes_service.baggage.metadata.0.name
            service_port = var.ingress_port
          }
        }
      }
    }

    rule {
      host = "baggage-${var.environment}-wk.${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}"
      http {
        path {
          path = "/${var.environment}.${var.client_name}.prints-cache/*"

          backend {
            service_name = kubernetes_service.baggage.metadata.0.name
            service_port = var.ingress_port
          }
        }
      }
    }
    rule {
      host = "baggage-${var.environment}-wk.${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}"
      http {
        path {
          path = "/${var.environment}.${var.client_name}.albums/*"

          backend {
            service_name = kubernetes_service.baggage.metadata.0.name
            service_port = var.ingress_port
          }
        }
      }
    }
  }
}