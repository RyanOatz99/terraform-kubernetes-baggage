resource "google_compute_global_address" "baggage_ingress" {
  name = "baggage-${var.environment}-${var.client_name}-wk-livelink-io"
}
