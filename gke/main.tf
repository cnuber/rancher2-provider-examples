terraform {
  backend "gcs" {
    bucket = "rancher2-terraform-states"
    prefix = "rancher2-terraform-states/my-cluster-name" ## Make sure this is unique per client

    credentials = "./cred.json"
  }
}

provider "rancher2" {
  api_url    = "${var.rancher2_api_url}"
  access_key = "${var.rancher2_access_key}"
  secret_key = "${var.rancher2_secret_key}"
}

resource "rancher2_cluster" "gke-shared-vpc-cluster" {
  name = "${var.cluster_name}"
  description = "${var.cluster_description}"
  gke_config {
    project_id = "${var.gke_project_id}"

    zone = "${var.gke_region}-a"
    locations = [
      "${var.gke_region}-b",
      "${var.gke_region}-c",
      "${var.gke_region}-a",
    ]

    master_version = "${var.gke_kubernetes_version}"
    machine_type = "${var.gke_node_size}"
    image_type = "COS"
    disk_type = "${var.gke_disk_type}"
    disk_size_gb = ${var.gpc_disk_size}

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]

    node_count = "${var.desired_node_count}"
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"

    enable_stackdriver_logging = true
    enable_stackdriver_monitoring = true
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "${var.master_cidr}"

    use_ip_aliases = true
    network = "projects/${var.gke_project_id}/global/networks/${var.gke_network_name}"
    sub_network = "projects/${var.gke_project_id}/regions/us-west1/subnetworks/${var.gke_subnetwork_name}"

    enable_network_policy_config = false

    enable_master_authorized_network = true
    master_authorized_network_cidr_blocks = [
      "10.0.0.0/16",
      "100.200.1.200",
      "0.0.0.0/0"
    ]

    enable_horizontal_pod_autoscaling = true
    enable_http_load_balancing = true
    enable_auto_upgrade = true
    enable_auto_repair = true
    enable_nodepool_autoscaling = true

    cluster_ipv4_cidr = "${var.cluster_cidr}" // can replace with own desired range

    credential = "${file("cred.json")}"

    enable_alpha_feature = false
    enable_kubernetes_dashboard = false
    enable_legacy_abac = false

    ip_policy_create_subnetwork = false
    ip_policy_subnetwork_name = ""
    ip_policy_cluster_secondary_range_name = ""
    ip_policy_cluster_ipv4_cidr_block = ""
    ip_policy_node_ipv4_cidr_block = ""
    ip_policy_services_ipv4_cidr_block = ""
    ip_policy_services_secondary_range_name = ""

    maintenance_window = ""
    node_pool = ""
    node_version = ""
    service_account = ""
    taints = []

  }
}
