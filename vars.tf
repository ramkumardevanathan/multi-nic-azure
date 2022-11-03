variable "region" {
  description = "The Azure Region in which all resources in this example should be created"
  default = "westus"
}


variable "subscriptionId" {}
variable "clientId" {}
variable "clientSecret" {}
variable "resourceGroup" {}
variable "tenantId" {}

variable "nics" {
   default = [ "10.0.0.4", "10.0.1.4", "10.0.2.4", "10.0.3.4", "10.0.0.5", "10.0.1.5", "10.0.2.5", "10.0.3.5" ]
}
variable "vnet_prefix" {
   default = "10.0.0.0/16"
}
variable "subnet_prefixes" {
   default = [ "10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
} 
