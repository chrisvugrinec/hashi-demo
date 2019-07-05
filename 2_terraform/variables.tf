resource "random_string" "random-namespace" {
  length  = 10
  special = false
}

variable "location" { default = "australiaeast" }
variable "rg" { default = "hashi-demo" }
variable "vnet" { default = "devopsvnet1" }
variable "subnet" { default = "devopssubnet1" }

variable "CLIENT_ID" {}
variable "CLIENT_SECRET" {}
variable "TENANT_ID" {}
# This is the Object ID for the SP (from AKS)
variable "OBJECT_ID" {}
# This is the Object ID for the ID from the operator
variable "OBJECT_ID2" {}
variable "SSH" {}
