terraform {
  backend "s3" {
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}

data "google_client_config" "default" {
}

data google_container_cluster k8s {
  name   = local.k8s_cluster_name
  region = local.resource_location
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.k8s.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.k8s.master_auth[0].cluster_ca_certificate,
  )
}



locals {
  k8s_cluster_name    = "k8s-${var.client_name}-${var.environment}"
  google_project_data = data.terraform_remote_state.client_google_projects.outputs.projects[var.environment]
  project_id          = local.google_project_data["project_id"]
  project_name        = local.google_project_data["project_name"]
  project_credentials = base64decode(local.google_project_data["project_service_account_key"])
  resource_location   = data.terraform_remote_state.client_metadata.outputs.location
  cluster_name        = "k8s-${var.client_name}-${var.environment}"
}

provider google {
  project     = local.project_id
  region      = local.resource_location
  credentials = local.project_credentials
}

provider google-beta {
  project     = local.project_id
  region      = local.resource_location
  credentials = local.project_credentials
}

data terraform_remote_state client_metadata {
  backend = "s3"
  config = {
    bucket = "livelink-terraform"
    key    = "client/${var.client_name}.tfstate"
    region = "eu-west-2"
  }
}
data terraform_remote_state client_google_projects {
  backend = "s3"
  config = {
    bucket = "livelink-terraform"
    key    = "client-projects/${var.client_name}.tfstate"
    region = "eu-west-2"
  }
}
data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    bucket = "livelink-terraform"
    key    = "infrastructure/storage/${var.cloud_provider}/${var.instance}/${var.environment}/${var.client_name}.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "livelink-terraform"
    key    = "infrastructure/dns/${var.client_name}.tfstate"
    region = "eu-west-2"
  }
}

provider "dns" {
  update {
    server        = data.terraform_remote_state.dns.outputs.server
    key_name      = data.terraform_remote_state.dns.outputs.key_name
    key_algorithm = data.terraform_remote_state.dns.outputs.key_algorithm
    key_secret    = data.terraform_remote_state.dns.outputs.key_secret
  }
}

data "terraform_remote_state" "docker_config" {
  backend = "s3"

  config = {
    bucket = "livelink-terraform"
    key    = "infrastructure/dockerhub.tfstate"
    region = "eu-west-2"
  }
}
