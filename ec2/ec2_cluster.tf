 terraform {
  backend "s3" {
  }
}

provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

provider "rancher2" {
  api_url    = "${var.rancher2_api_url}"
  access_key = "${var.rancher2_access_key}"
  secret_key = "${var.rancher2_secret_key}"
}

resource "aws_s3_bucket" "etcd_backup_store" {
  bucket = "${var.cluster_name}-cluster-backup-etcd-rancher"
  region = "${var.aws_region}"
  acl    = "private"
  tags = {
    Name        = "${var.cluster_name}-cluster-backup-etcd-rancher"
    Owner = "${var.owner_tag}"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.cluster_name}-cluster"
  public_key = "${file(var.ssh_public_key_file)}"
}

data "aws_subnet_ids" "available" {
  vpc_id = "${var.vpc_id}"
  filter {
  name   = "tag:Name"
  values = ["*private*"]       # insert values here
  }
}

data "aws_subnet" "selected" {
  count = "3"
  id = "${tolist(data.aws_subnet_ids.available.ids)[count.index]}"
}

resource "aws_security_group" "cluster_sg" {
  name   = "${var.cluster_name}-rancher-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "rancher2_cluster" "cluster" {
  name = "${var.cluster_name}"
  description = "${var.cluster_description}"
  rke_config {
    network {
      plugin = "canal"
    }
  }
}

resource "rancher2_node_template" "nodetemplate" {
  count = "3"
  name = "${var.cluster_name}-az${count.index}"
  description = "node template for ${var.cluster_name}"
  use_internal_ip_address = "true"
  amazonec2_config {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
    ami = "ami-d15a75c7"
    instance_type = "${var.control_plane_instance_type}"
    root_size = "50"
    security_group = ["${aws_security_group.cluster_sg.name}"]
    ssh_user = "ubuntu"
    subnet_id = "${tolist(data.aws_subnet_ids.available.ids)[count.index]}"
    use_private_address = "true"
    vpc_id = "${var.vpc_id}"
    zone = substr("${data.aws_subnet.selected[count.index].availability_zone}", 9, 1)
  }
}

resource "rancher2_node_pool" "control_plane_node_pool" {
  count = "3"
  cluster_id =  "${rancher2_cluster.cluster.id}"
  name = "${var.cluster_name}-cp-node-pool-az${count.index}"
  hostname_prefix =  "${var.cluster_name}-cp${count.index}"
  node_template_id = "${rancher2_node_template.nodetemplate[count.index].id}"
  quantity = 1
  control_plane = true
  etcd = false
  worker = false
  depends_on = [rancher2_node_pool.etcd_node_pool]
}

resource "rancher2_node_pool" "etcd_node_pool" {
  count = "3"
  cluster_id =  "${rancher2_cluster.cluster.id}"
  name = "${var.cluster_name}-etcd-node-pool-az${count.index}"
  hostname_prefix =  "${var.cluster_name}-etcd${count.index}"
  node_template_id = "${rancher2_node_template.nodetemplate[count.index].id}"
  quantity = 1
  control_plane = false
  etcd = true
  worker = false
  depends_on = [rancher2_node_template.nodetemplate]
}

resource "rancher2_node_pool" "worker_node_pool" {
  count = "3"
  cluster_id =  "${rancher2_cluster.cluster.id}"
  name = "${var.cluster_name}-worker-node-pool-az${count.index}"
  hostname_prefix =  "${var.cluster_name}-worker${count.index}"
  node_template_id = "${rancher2_node_template.nodetemplate[count.index].id}"
  quantity = 1
  control_plane = false
  etcd = false
  worker = true
  depends_on = [rancher2_node_pool.etcd_node_pool]
}

resource "rancher2_etcd_backup" "cluster-backups" {
  backup_config {
    enabled = true
    interval_hours = 20
    retention = 10
    s3_backup_config {
      access_key = "${var.aws_access_key}"
      bucket_name = "${var.cluster_name}-cluster-backup-etcd-rancher"
      endpoint = "s3.amazonaws.com"
      region = "${var.aws_region}"
      secret_key = "${var.aws_secret_key}"
    }
  }
  cluster_id = "${rancher2_cluster.cluster.id}"
  name = "${var.cluster_name}-etcd-backup"
  filename = "${var.cluster_name}-etcd-backup"
}
