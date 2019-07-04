# hashi-demo
demo showing Terraform creating Azure Kubernetes Cluster and implement service mesh with Consul 

## Packer
*1_packer* is optional, use this if you would like to spinup a buildagent VM later on the demo.
The output of the 1_packer is a Azure VM image named: buildagent-image within the hashi-demo-images resourcegroup. You need to create the resource group with the command: ```az group create -n hashi-demo-images -l australiaeast``` and make sure you have the following env variables are set:
- TF_VAR_CLIENT_ID
- TF_VAR_CLIENT_SECRET
- TF_VAR_TENANT_ID
- TF_VAR_SUBSCRIPTION_ID
before running the ```packer build buildagent-azure.json``` command

