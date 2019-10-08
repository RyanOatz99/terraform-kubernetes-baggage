resource "google_compute_managed_ssl_certificate" "ssl" {
  provider = "google-beta"

  name = "baggage-${var.environment}-${var.client_name}-wk-livelink-io-ssl"

  managed {
    domains = ["baggage-${var.environment}-wk.${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}."]
  }
}
