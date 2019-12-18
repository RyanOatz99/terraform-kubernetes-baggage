terraform {
  backend "s3" {
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}

data "terraform_remote_state" "k8s" {
  backend = "s3"

  config = {
    bucket = "livelink-terraform"
    key    = "infrastructure/k8s/${var.cloud_provider}/${var.environment}/${var.client_name}.tfstate"
    region = "eu-west-2"
  }
}

provider "kubernetes" {
  host               = data.terraform_remote_state.k8s.outputs.host
  username           = data.terraform_remote_state.k8s.outputs.cluster_username
  password           = data.terraform_remote_state.k8s.outputs.cluster_password
  client_certificate = base64decode(data.terraform_remote_state.k8s.outputs.client_certificate)
  client_key         = base64decode(data.terraform_remote_state.k8s.outputs.client_key)
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.k8s.outputs.cluster_ca_certificate,
  )
}

locals {
  google_project_data = data.terraform_remote_state.client_google_projects.outputs.projects[var.environment]
  project_id = local.google_project_data["project_id"]
  project_name = local.google_project_data["project_name"]
  project_credentials = base64decode(local.google_project_data["project_service_account_key"])
  resource_location = data.terraform_remote_state.client_metadata.outputs.location
  cluster_name = "k8s-${var.client_name}-${var.environment}"
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
    key = "client/${var.client_name}.tfstate"
    region = "eu-west-2"
  }
}
data terraform_remote_state client_google_projects {
  backend = "s3"
  config = {
    bucket = "livelink-terraform"
    key = "client-projects/${var.client_name}.tfstate"
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
