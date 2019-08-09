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
    cloud_provider {
      name = "aws"
    }
    network {
      plugin = "canal"
    }
  }
}

<<<<<<< HEAD
resource "rancher2_node_template" "nodetemplate" {
  count = "3"
  name = "${var.cluster_name}-az${count.index}"
=======
resource "rancher2_node_template" "control_plane_nodetemplate" {
  count = "${var.control_plane_count}"
  name = "${var.cluster_name}-cp-node-template-az${count.index}"
>>>>>>> marcel
  description = "node template for ${var.cluster_name}"
  use_internal_ip_address = "true"
  amazonec2_config {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
<<<<<<< HEAD
    ami = "ami-d15a75c7"
    iam_instance_profile = "${aws_iam_instance_profile.node_instance_profile.name}"
    instance_type = "${var.control_plane_instance_type}"
    root_size = "50"
    security_group = ["${aws_security_group.cluster_sg.name}"]
    ssh_user = "ubuntu"
    subnet_id = "${tolist(data.aws_subnet_ids.available.ids)[count.index]}"
    use_private_address = "true"
    vpc_id = "${var.vpc_id}"
    zone = substr("${data.aws_subnet.selected[count.index].availability_zone}", 9, 1)
=======
    ami = "${var.ami_id}"
    instance_type = "${var.control_plane_instance_type}"
    root_size = "50"
    security_group = ["${aws_security_group.cluster_sg.name}"]
    ssh_keypath = "${var.ssh_public_key_file}"
    ssh_user = "${var.ssh_username}"
    subnet_id = "${tolist(data.aws_subnet_ids.available.ids)[count.index]}"
    vpc_id = "${var.vpc_id}"
    zone = substr("${data.aws_subnet.selected[count.index].availability_zone}", 9, 1)
    use_private_address = "true"
  }
}

resource "rancher2_node_template" "worker_nodetemplate" {
  count = "${var.worker_count}"
  name = "${var.cluster_name}-worker-node-template-az${count.index}"
  description = "node template for ${var.cluster_name}"
  use_internal_ip_address = "true"
  amazonec2_config {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
    ami = "${var.ami_id}"
    instance_type = "${var.worker_instance_type}"
    root_size = "50"
    security_group = ["${aws_security_group.cluster_sg.name}"]
    ssh_keypath = "${var.ssh_public_key_file}"
    ssh_user = "${var.ssh_username}"
    subnet_id = "${tolist(data.aws_subnet_ids.available.ids)[count.index]}"
    vpc_id = "${var.vpc_id}"
    zone = substr("${data.aws_subnet.selected[count.index].availability_zone}", 9, 1)
    use_private_address = "true"
    tags = "node-role.kubernetes.io/worker-web,true"
  }
  labels = {
    "node-role.kubernetes.io/worker-web" = "true"
>>>>>>> marcel
  }

}

resource "rancher2_node_pool" "control_plane_node_pool" {
  count = "${var.control_plane_count}"
  cluster_id =  "${rancher2_cluster.cluster.id}"
  name = "${var.cluster_name}-cp-node-pool-az${count.index}"
<<<<<<< HEAD
  hostname_prefix =  "${var.cluster_name}-cp${count.index}"
  node_template_id = "${rancher2_node_template.nodetemplate[count.index].id}"
=======
  hostname_prefix =  "${var.cluster_name}-cp-${count.index}"
  node_template_id = "${rancher2_node_template.control_plane_nodetemplate[count.index].id}"
>>>>>>> marcel
  quantity = 1
  control_plane = true
  etcd = false
  worker = false
  depends_on = [rancher2_node_pool.etcd_node_pool]
}

resource "rancher2_node_pool" "etcd_node_pool" {
  count = "${var.etcd_count}"
  cluster_id =  "${rancher2_cluster.cluster.id}"
  name = "${var.cluster_name}-etcd-node-pool-az${count.index}"
<<<<<<< HEAD
  hostname_prefix =  "${var.cluster_name}-etcd${count.index}"
  node_template_id = "${rancher2_node_template.nodetemplate[count.index].id}"
=======
  hostname_prefix =  "${var.cluster_name}-etcd-${count.index}"
  node_template_id = "${rancher2_node_template.control_plane_nodetemplate[count.index].id}"
>>>>>>> marcel
  quantity = 1
  control_plane = false
  etcd = true
  worker = false
<<<<<<< HEAD
  depends_on = [rancher2_node_template.nodetemplate]
=======
  depends_on = [rancher2_node_template.control_plane_nodetemplate,aws_security_group.cluster_sg]

>>>>>>> marcel
}

resource "rancher2_node_pool" "worker_node_pool" {
  count = "${var.worker_count}"
  cluster_id =  "${rancher2_cluster.cluster.id}"
  name = "${var.cluster_name}-worker-node-pool-az${count.index}"
<<<<<<< HEAD
  hostname_prefix =  "${var.cluster_name}-worker${count.index}"
  node_template_id = "${rancher2_node_template.nodetemplate[count.index].id}"
=======
  hostname_prefix =  "${var.cluster_name}-worker-${count.index}"
  node_template_id = "${rancher2_node_template.worker_nodetemplate[count.index].id}"
>>>>>>> marcel
  quantity = 1
  control_plane = false
  etcd = false
  worker = true
<<<<<<< HEAD
  depends_on = [rancher2_node_pool.etcd_node_pool]
=======
  depends_on = [rancher2_node_pool.control_plane_node_pool,rancher2_node_template.worker_nodetemplate]
  labels = {
    "node-role.kubernetes.io/worker-web" = "true"
  }
>>>>>>> marcel
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
