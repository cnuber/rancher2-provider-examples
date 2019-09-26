#!/bin/bash
export CLUSTER_NAME=$1

terraform init -backend-config=state_stores/backends/backend-$CLUSTER_NAME.conf -var-file=tfvars/$2.tfvars
terraform apply -auto-approve -var-file=tfvars/$2.tfvars -var cluster_name="$CLUSTER_NAME" -var cluster_description="K8s cluster for $CLUSTER_NAME"
