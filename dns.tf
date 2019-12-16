resource "dns_a_record_set" "baggage_ingress" {
  zone = "${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}."
  name = "baggage-${var.environment}-wk"

  addresses = [
    google_compute_global_address.baggage_ingress.address
  ]
}
