resource "kubernetes_stateful_set" "baggage" {
  metadata {
    name = var.set_name

    labels = {
      "app.kubernetes.io/name" = var.set_name
      "app.kubernetes.io/part-of" = "baggage"
    }

    namespace = var.namespace
  }

  spec {
    replicas = var.replicas
    revision_history_limit = 5

    selector {
      match_labels = {
        "app.kubernetes.io/name" = var.set_name
        "app.kubernetes.io/part-of" = "baggage"
      }
    }

    service_name = kubernetes_service.baggage.metadata[0].name

    update_strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = var.set_name
          "app.kubernetes.io/part-of" = "baggage"
        }
      }

      spec {
        security_context {
          fs_group = var.fs_group
          run_as_user = var.run_as
        }
        image_pull_secrets {
          name = "docker-cfg"
        }

        volume {
          name = "baggage-config"

          secret {
            default_mode = "0555"
            secret_name         = kubernetes_secret.config.metadata[0].name
          }
        }
      
        image_pull_secrets {
          name = kubernetes_secret.docker_secret.metadata[0].name
        }

        container {
          image             = "livelink/baggage:${var.image_version}"
          name              = "baggage-worker"
          image_pull_policy = "Always"

          command = [
            "bundle",
          ]

          volume_mount {
            name       = "baggage-config"
            mount_path = "/usr/src/app/config"
          }
          args = [
            "exec",
            "ruby",
            "-S",
            "puma",
            "config.ru",
            "-p",
            "9292",
          ]

          port {
            name           = "baggage"
            container_port = 9292
          }

          env {
            name = "MEMCACHE_SERVER_PODS"
            value = join(",", module.memcache.servers)
          }
        }
      }
    }
  }
}