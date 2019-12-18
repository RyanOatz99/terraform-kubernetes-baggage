resource "google_compute_managed_ssl_certificate" "ssl" {
  provider = google-beta

  name = "baggage-${var.environment}-${var.client_name}-${var.instance}-livelink-io-ssl"

  managed {
    domains = ["baggage-${var.environment}-${var.instance}.${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}."]
  }
}
