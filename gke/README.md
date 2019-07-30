# Rancher2 terraform provider example for creating a GKE cluster

This project provides an example for creating a cluster through the Rancher2 Terraform provider in GKE

### Prerequisites

- an existing Rancher management server (v2.2.x)
- terraform 0.12.x [terraform client download](https://www.terraform.io/downloads.html)
- an GKE profile with sufficient access to deploy the necessary resources
- a VPC and associated networks to deploy to at GKE
- a cloud bucket at Google Cloud to store the Terraform state in

### Configuring deployment settings

cp terraform.tfvars.example terraform.tfvars  # copy the example var file to one for this cluster

vim terraform.tfvars # set the values to the desired values


### Running the terraform (note that it's always important to check the plan output before applying to ensure you are getting the intended results)

authenticate to google cloud and create a cred.json file in the current directory

terraform init 

terraform plan 

terraform apply




