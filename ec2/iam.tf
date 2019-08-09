resource "aws_iam_role_policy" "node_role_policy" {
  name   = "${var.cluster_name}_node_role_policy"
  role = "${aws_iam_role.node_role.id}"
  policy = "${file("aws/node-iam-policy.json")}"
}

resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node_role"
  assume_role_policy = "${file("aws/assume-role-policy.json")}"
}

resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "${var.cluster_name}-node_instance_profile"
  role = "${aws_iam_role.node_role.name}"
}
