output "baggage_ingress" {
  value = kubernetes_ingress.baggage_ingress.load_balancer_ingress
}

output "authenticator_key" {
  value = random_string.authenticator_key.result
}

output "api_key" {
  value = random_string.api_key.result
}


output "dns" {
  value = "${dns_a_record_set.baggage_ingress.name}.${var.client_name}.${data.terraform_remote_state.dns.outputs.domain}"
}

output "instance_name" {
  value = local.instance_name
}
