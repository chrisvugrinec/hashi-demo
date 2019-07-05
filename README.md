# hashi-demo
demo showing Terraform creating Azure Kubernetes Cluster and implement service mesh with Consul 

## Packer
1_packer is optional, use this if you would like to spinup a buildagent VM later on the demo.
The output of the 1_packer is a Azure VM image named: buildagent-image within the hashi-demo-images resourcegroup. You need to create the resource group with the command: ```az group create -n hashi-demo-images -l australiaeast``` and make sure you have set the following env variables:
- TF_VAR_CLIENT_ID
- TF_VAR_CLIENT_SECRET
- TF_VAR_TENANT_ID
- TF_VAR_SUBSCRIPTION_ID
before running the ```packer build buildagent-azure.json``` command

## Terraform

This will install the following on Azure:
- AKS; A Kubernetes Cluster using Azure Kubernetes Service
- Keyvault; for storge of secrets/ certificates. optional
- Network; contains network configuration for VM. optional
- VM; an Azure VM based on the packer build image. optional

Choose which parts you like to install by editing the main.tf.

## Kube
The Kube section contains 2 scripts, you need to execute sequentially in order to do the consul demo.
- get-credentials.sh  Makes communication between you AKS cluster (master API) and your client possible
- install-helms.sh  Helm is used as K8 package manager, will be used to install consul (next chapter)

## Consul
This is meat of the service mesh implementation. By executing the install.sh script you are installing a simple helm chart that contains all that is needed for this demo. Please be advised that this is not an enterprise implementation, you can find guides for these kind of tracks here: https://www.consul.io/docs/guides/index.html

configure the installation packes by editing the values in the 4_consul/values.yaml file. This is not required for this demo.
The install.sh executes this: ```helm install -f values.yaml ./helm --name hashi-consul-demo``` After installation you should see the hashi-consul-demo chart installed when you execute: ```helm ls``

After installation change the hashi-consul-demo-consul-ui service to type LoadBalancer:
```kubectl edit svc hashi-consul-demo-consul-ui``` change ```type: ClusterIP``` to ```type: LoadBalancer```
Open the browser and navigate to the public ip address shown in the service overview: ```kubectl get svc```

## Apps
There are 4 version of apps, which can be installed per directory with the ```kubectl apply -f ./folder name``` command:
- 01-yaml-minimal; this is a traditional app. Which exposes the deployment as a K8 service. In a production world where we implement a service mesh we will forbid this with a policy or rbac. For example forbid the usage of K8 Service by restricting the possibility to create K8 services. This service will also not be discovered (and thus visible in the ui) by Consul.
- 02-yaml-discover; This is not using the K8 services anymore but each pod is injected with a initcontainer that implements the hashicorp/counting-init image, making it discoverable by consul. Communication between service is not possible now.
- 03-yaml-connect; Uses the same initconnector as the previous step. However the same container is now using Connect using the init container as Proxy (ambassador pattern). Communication between services can now be made possible. Granular configuration can be done with CLI/config of the portal. Demo this.
- 04-yaml-connect-envoy; This implement the same pattern as the previous app but enforce the usage of ENVOY proxy, which is an industry standard. More possibilities with TLS are possible here. (not covered in demo)





