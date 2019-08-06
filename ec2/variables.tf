variable "aws_access_key" {
  default     = ""
}

variable "aws_secret_key" {
  default     = ""
}

variable "ssh_username" {
  default     = ""
}

variable "cluster_name" {
  default     = ""
}

variable "cluster_description" {
  default     = ""
}

variable "aws_profile" {
  default     = ""
}
variable "aws_region" {
  default     = ""
}
variable "domain_name" {
  default     = ""
}
variable "dns_name" {
  default     = ""
}
variable "server_instance_type" {
  default     = ""
}
variable "worker_instance_type" {
  default     = "t3.large"
}
variable "worker_count" {
  default     = "3"
}
variable "control_plane_count" {
  default     = "3"
}
variable "etcd_count" {
  default     = "3"
}
variable "control_plane_instance_type" {
  default     = "m5.large"
}
variable "vpc_id" {
  default     = ""
}
variable "vpc_cidr" {
  default     = ""
}
variable "aws_subnet_ids" {
  default     = ""
}
variable "ssh_public_key_file" {
  default     = ""
}
variable "ssh_key_pair_name" {
  default     = ""
}
variable "owner_tag" {
  default     = ""
}
variable "rancher_version" {
  default     = ""
}
variable "kubernetes_version" {
  default     = ""
}
variable "docker_version" {
  default     = ""
}
variable "rancher_ssl_type" {
  default     = ""
}
variable "letsencrypt_email" {
  default     = ""
}
variable "rancher2_api_url" {
  default     = ""
}
variable "rancher2_access_key" {
  default     = ""
}
variable "rancher2_secret_key" {
  default     = ""
}
