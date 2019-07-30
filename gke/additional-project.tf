resource "rancher2_project" "gitlab" {
  name = "gitlab"
  cluster_id = "${rancher2_cluster.gke-shared-vpc-cluster.id}"
}
