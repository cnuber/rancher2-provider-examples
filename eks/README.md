# Rancher2 terraform provider example for creating an EKS cluster

This project provides an example for creating a cluster through the Rancher2 Terraform provider in EKS

### Prerequisites

- an existing Rancher management server (v2.2.x)
- terraform 0.12.x [terraform client download](https://www.terraform.io/downloads.html)
- an AWS profile with sufficient access to deploy the necessary resources
- a VPC and associated subnets to deploy to at AWS
- an S3 bucket at Google Cloud to store the Terraform state in (optional)

### Configuring deployment settings

cp terraform.tfvars.example terraform.tfvars  # copy the example var file to one for this cluster

vim terraform.tfvars # set the values to the desired values


### Running the terraform (note that it's always important to check the plan output before applying to ensure you are getting the intended results)

terraform init 

terraform plan 

terraform apply




