variable "proxmox_endpoint"    { type = string }
variable "proxmox_username"    { type = string }
variable "proxmox_password"    { type = string; sensitive = true }
variable "proxmox_node"        { type = string }
variable "cluster_name"        { type = string; default = "k3s-lab" }
variable "template_vm_id"      { type = number }
variable "cloudinit_datastore" { type = string }
variable "master_ip"           { type = string }
variable "network_gateway"     { type = string }
variable "ssh_public_keys"     { type = list(string) }
variable "k3s_token"           { type = string; sensitive = true }

variable "workers" {
  type    = map(string)
  default = {
    "worker-1" = "132"
    "worker-2" = "133"
  }
}
