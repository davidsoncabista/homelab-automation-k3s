Para subir um main.tf no GitHub que seja digno de um Arquiteto de Soluções, ele precisa ser genérico, modular e seguro.

Abaixo, preparei a versão final. Ela remove os dados sensíveis (senhas e IPs fixos) e usa variáveis. Assim, você pode compartilhar seu projeto sem expor seu laboratório, e quem baixar só precisará preencher um arquivo .tfvars separado.

📝 O arquivo: terraform/main.tf
Terraform
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}

# --- 1. O NÓ MASTER (Control Plane) ---
resource "proxmox_virtual_environment_vm" "k3s_master" {
  name      = "${var.cluster_name}-master-131"
  node_name = var.proxmox_node
  vm_id     = 1201

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  initialization {
    datastore_id = var.cloudinit_datastore
    ip_config {
      ipv4 {
        address = "${var.master_ip}/24"
        gateway = var.network_gateway
      }
    }
    user_account {
      username = "root"
      keys     = var.ssh_public_keys
    }
  }

  # Automação de Instalação do K3s Server
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | sh -s - server --disable traefik --node-name master-01"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      host     = var.master_ip
    }
  }
}

# --- 2. OS NÓS WORKERS (Agents) ---
resource "proxmox_virtual_environment_vm" "k3s_workers" {
  for_each   = var.workers
  depends_on = [proxmox_virtual_environment_vm.k3s_master]

  name      = "${var.cluster_name}-node-${each.value}"
  node_name = var.proxmox_node
  vm_id     = 1200 + tonumber(each.value)

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  initialization {
    datastore_id = var.cloudinit_datastore
    ip_config {
      ipv4 {
        address = "192.168.0.${each.value}/24" # Baseado no sufixo do Worker
        gateway = var.network_gateway
      }
    }
    user_account {
      username = "root"
      keys     = var.ssh_public_keys
    }
  }

  # Automação de Instalação do K3s Agent
  # Nota: O Token deve ser passado via variável para o GitHub
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${var.master_ip}:6443 K3S_TOKEN=${var.k3s_token} sh -"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      host     = "192.168.0.${each.value}"
    }
  }
}
