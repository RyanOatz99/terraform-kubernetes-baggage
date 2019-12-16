variable "client_name" {
  description = "Name of Client"
}

variable "environment" {
  description = "Environment to run in"
}

variable "cloud_provider" {
  description = "Place where this runs"
  default     = "gcp"
}

variable "image_version" {
  description = "Version of the baggage container to run"
  default     = "latest"
}

variable "ingress_port" {
  description = "Port Service listens on"
  default     = "9292"
}

variable "min_threads" {
  description = "Minimum number of threads per baggage worker"
  default     = 1
}

variable "max_threads" {
  description = "Maximum number of threads per baggage worker"
  default     = 1
}

variable "workers" {
  description = "Number of worker processes to spawn"
  default     = 1
}

variable "memcache_replicas" {
  description = "Number of memcache pods to spin out"
  default = 3
}

variable "memcache_resource_requests" {
  type = "map"

  description = <<EOF
Resource Requests
ref http://kubernetes.io/docs/user-guide/compute-resources/
resource_requests = {
  memory = "64Mi"
  cpu = "50m"
}
EOF

  default = {
    cpu = "50m"
    memory = "64Mi"
  }
}

variable "memcache_resource_limits" {
  type = "map"

  description = <<EOF
Memcache Resource Limits
ref http://kubernetes.io/docs/user-guide/compute-resources/
resource_requests = {
  memory = "64Mi"
  cpu = "50m"
}
EOF

  default = {
    cpu = "150m"
    memory = "256Mi"
  }
}

variable "instance" {
  description = "Name for my baggage"
  default = "default"
}
variable "namespace" {
  description = "default namespace for pods"
  default = "bg-livelink-test"
}

variable "run_as" {
  description = "uid to run as"
  default = 65534
}

variable "fs_group" {
  description = "FS Group for Security context"
  default = 65534
}

variable "authenticator_version" {
  description = "Increment to rotate keys"
  default = 1
}

variable "set_name" {
  description = "local name of baggage instance sets"
  default = "baggage"
}

variable "replicas" {
  description = "Number of Baggage Pods to spin out in stateful set"
  default = 3
}

variable "docker_config" {
  description = "Docker Authentication JSON"
}
