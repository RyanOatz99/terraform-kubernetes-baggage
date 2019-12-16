resource "random_string" "authenticator_key" {
  length  = 32
  special = false
  upper   = false
  keepers = {
    version = var.authenticator_version
  }
}

resource "random_string" "api_key" {
  length  = 10
  special = false
  upper   = false

  keepers = {
    version = var.authenticator_version
  }
}

resource "random_string" "config_name" {
  length      = 8
  special     = false
  min_lower   = 2
  upper       = false
  min_numeric = 2
  keepers = {
    "baggage.rb"        = local.baggage_rb
    "puma.rb"           = local.puma_rb
    "authenticator.txt" = local.authenticator_txt
  }
}


resource "kubernetes_secret" "config" {

  metadata {
    name      = "${local.instance_name}-${random_string.config_name.result}"
    namespace = local.namespace
  }

  type = "Opaque"

  data = {
    "authenticator.txt" = local.authenticator_txt
    "puma.rb"           = local.puma_rb
    "baggage.rb"        = local.baggage_rb
  }
}

locals {
  policies = [
    for bucket_name, bucket_details in data.terraform_remote_state.storage.outputs.buckets : <<EOF
policy '${local.instance_name}.${bucket_name}' do
  read do
    backend 'fog',
            fog_options: { provider: 'google',
                           google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                           google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
            scope: '${bucket_details}'
  end
  write do
    sync 'fog',
         fog_options: { provider: 'google',
                        google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                        google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
         scope: '${bucket_details}'
  end
end
EOF
  ]
  authenticator_txt = "${random_string.api_key.result}:${random_string.authenticator_key.result}:read,write"

  puma_rb = <<EOF
threads ${var.min_threads},${var.max_threads}
workers ${var.workers}
preload_app!
EOF

  baggage_rb = <<EOF
module Baggage
  MEMCACHE_SERVERS = ENV['MEMCACHE_SERVER_PODS'].split(',').freeze
end

hostname 'baggage-${var.environment}-${var.client_name}-wk.livelinklabs.com'
${join("\n", local.policies)}
EOF

}

