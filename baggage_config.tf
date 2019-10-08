resource "random_string" "authenticator_key" {
  length  = 32
  special = false
  upper   = false
  keepers = {
    version = var.authenticator_version
  }
}

resource "random_string" "api_key" {
  length = 10
  special = false
  upper = false

  keepers = {
    version = var.authenticator_version
  }
}

resource "kubernetes_secret" "config" {

  metadata {
    name = var.set_name
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    "authenticator.txt" = data.null_data_source.config.outputs["authenticator_txt"]
    "puma.rb"           = data.null_data_source.config.outputs["puma_rb"]
    "baggage.rb"        = data.null_data_source.config.outputs["baggage_rb"]
  }
}

data "null_data_source" "config" {
  inputs = {
    authenticator_txt = "${random_string.api_key.result}:${random_string.authenticator_key.result}:read,write"

    puma_rb           = <<EOF
threads ${var.min_threads},${var.max_threads}
workers ${var.workers}
preload_app!
EOF

    baggage_rb = <<EOF

module Baggage
  MEMCACHE_SERVERS = ENV['MEMCACHE_SERVER_PODS'].split(',').freeze
end

hostname 'baggage-${var.environment}-${var.client_name}-wk.livelinklabs.com'

policy '${var.environment}.${var.client_name}.prints' do
  cache servers: Baggage::MEMCACHE_SERVERS

  authenticator type: :file, file: 'config/authenticator.txt'
  read do
    backend 'fog',
            fog_options: { provider: 'google',
                           google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                           google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
            scope: '${data.terraform_remote_state.storage.outputs.buckets["prints"]}'
  end

  write do
    sync 'fog',
         fog_options: { provider: 'google',
                        google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                        google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
         scope: '${data.terraform_remote_state.storage.outputs.buckets["prints"]}'
  end

  delete do
    sync 'fog',
         fog_options: { provider: 'google',
                        google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                        google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
         scope: '${data.terraform_remote_state.storage.outputs.buckets["prints"]}'
  end
end

policy '${var.environment}.${var.client_name}.prints-cache' do
  cache servers: Baggage::MEMCACHE_SERVERS

  authenticator type: :file, file: 'config/authenticator.txt'

  read do
    backend 'fog',
            fog_options: { provider: 'google',
                           google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                           google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
            scope: '${data.terraform_remote_state.storage.outputs.buckets["prints_cache"]}'
  end

  write do
    auth
    sync 'fog',
          fog_options: { provider: 'google',
                         google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                         google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
          scope: '${data.terraform_remote_state.storage.outputs.buckets["prints_cache"]}'
  end

  delete do
    auth
    sync 'fog',
          fog_options: { provider: 'google',
                         google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                         google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
          scope: '${data.terraform_remote_state.storage.outputs.buckets["prints_cache"]}'
  end
end

policy '${var.environment}.${var.client_name}.albums' do
  cache servers: Baggage::MEMCACHE_SERVERS

  authenticator type: :file, file: 'config/authenticator.txt'
  read do
    backend 'fog',
            fog_options: { provider: 'google',
                           google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                           google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
                           scope: '${data.terraform_remote_state.storage.outputs.buckets["albums"]}'
  end

  write do
    sync 'fog',
         fog_options: { provider: 'google',
                        google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                        google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
         scope: '${data.terraform_remote_state.storage.outputs.buckets["albums"]}'
  end

  delete do
    sync 'fog',
         fog_options: { provider: 'google',
                        google_project: '${data.terraform_remote_state.storage.outputs.storage_account_project}',
                        google_json_key_string: '${data.terraform_remote_state.storage.outputs.private_key_json}'},
                        scope: '${data.terraform_remote_state.storage.outputs.buckets["albums"]}'
  end
end
EOF

  }
}

