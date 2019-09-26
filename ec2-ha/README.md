# Rancher2 terraform provider example for creating an EC2 cluster

This project provides an example for creating a cluster through the Rancher2 Terraform provider in EC2

### Prerequisites

- an existing Rancher management server (v2.2.x)
- terraform 0.12.x [terraform client download](https://www.terraform.io/downloads.html)
- an AWS profile with sufficient access to deploy the necessary resources
- a VPC and associated subnets to deploy to at AWS
- an S3 bucket at AWS Cloud to store the Terraform state in (optional)

### Creating the S3 storage bucket

export CLUSTER_NAME=mycluster # set this to the desired cluster name (must be consistent everywhere)

cd state_stores # switch to the state storage directory

cp terraform.tfvars.example $CLUSTER_NAME.tfvars  # copy the example var file to one for this cluster

vim $CLUSTER_NAME.tfvars # set the values to the desired values

terraform init

terraform plan -var-file=$CLUSTER_NAME.tfvars

terraform apply -var-file=$CLUSTER_NAME.tfvars

### Configuring deployment settings

from the ec2 directory in this repo:

export CLUSTER_NAME=mycluster # set this to the desired cluster name (must be consistent everywhere)

cp terraform.tfvars.example tfvars/$CLUSTER_NAME.tfvars # copy the example tfvars to one for this cluster

vim tfvars/$CLUSTER_NAME.tfvars # modify the vars for your cluster deployment

### Running the terraform (note that it's always important to check the plan output before applying to ensure you are getting the intended results)

terraform init -backend-config=state_stores/backends/backend-$CLUSTER_NAME.conf -var-file=tfvars/$CLUSTER_NAME.tfvars

terraform plan -var-file=tfvars/$CLUSTER_NAME.tfvars -var cluster_name="$CLUSTER_NAME" -var cluster_description="K8s cluster for $CLUSTER_NAME"

terraform apply -var-file=tfvars/$CLUSTER_NAME.tfvars -var cluster_name="$CLUSTER_NAME" -var cluster_description="K8s cluster for $CLUSTER_NAME"


