 terraform {
  backend "s3" {
  }
}

provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks_cluster_role"
  assume_role_policy = "${file("aws/assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "attach-eks-cluster-policy" {
  role       = "${aws_iam_role.eks_cluster_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "attach-eks-service-policy" {
  role       = "${aws_iam_role.eks_cluster_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_security_group" "cluster_sg" {
  name   = "${var.cluster_name}-eks-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = "0"
    from_port   = "0"
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    to_port     = "0"
    from_port   = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#data "aws_subnet_ids" "available" {
#  vpc_id = "${var.vpc_id}"
#}

provider "rancher2" {
  api_url    = "${var.rancher2_api_url}"
  access_key = "${var.rancher2_access_key}"
  secret_key = "${var.rancher2_secret_key}"
}

resource "rancher2_cluster" "eks-cluster" {
  name = "${var.cluster_name}"
  description = "${var.cluster_description}"
  eks_config {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    security_groups = ["${aws_security_group.cluster_sg.id}"]
    service_role = "${aws_iam_role.eks_cluster_role.name}"
    subnets = [
      "${var.eks_subnet1}",
      "${var.eks_subnet2}",
      "${var.eks_subnet3}"
    ]
    virtual_network = "${var.vpc_id}"
    associate_worker_node_public_ip = "false"
    instance_type = "${var.aws_instance_type}"
    kubernetes_version = "${var.eks_kubernetes_version}"
    minimum_nodes = "${var.eks_min_nodes}"
    maximum_nodes = "${var.eks_max_nodes}"
    node_volume_size = "${var.eks_node_volume_size}"
    region = "${var.aws_region}"
  }
}
