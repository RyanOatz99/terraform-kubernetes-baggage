resource "dns_a_record_set" "baggage_ingress" {
  zone = "${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}."
  name = "baggage-${var.environment}-wk"

  addresses = [
    kubernetes_ingress.baggage_ingress.load_balancer_ingress.0.ip
  ]
}
