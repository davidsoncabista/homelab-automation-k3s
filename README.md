# Homelab Automation: K3s on Proxmox 9

Este repositório documenta o provisionamento automatizado de um cluster K3s utilizando **Terraform** e **Cloud-Init** em um ambiente **Proxmox VE 9**.

## Stack Técnica
* **Orquestrador:** Terraform
* **Provider:** [bpg/proxmox](https://github.com/bpg/terraform-provider-proxmox) (v0.70.0)
* **Hypervisor:** Proxmox VE 9.x
* **Storage:** ZFS (com compressão e snapshots)

---

##  Lessons Learned: Desafios do Proxmox 9 & ZFS

Durante o desenvolvimento deste projeto, identificamos comportamentos específicos da API do Proxmox 9 em conjunto com storages ZFS que causavam falhas no provisionamento. Abaixo estão os problemas e as soluções implementadas:

### 1. Erro: `Requested resource does not exist`
**O Problema:** No Proxmox 9, ao disparar múltiplos clones simultâneos, a API pode responder com sucesso antes que o banco de dados interno de recursos do Proxmox tenha registrado a nova VM. O Terraform, ao tentar configurar a rede imediatamente, recebe um erro 404 (recurso não encontrado).

**A Solução:** * Implementação de `timeout_clone` e `timeout_create` elevados (600s).
* Uso da flag `-parallelism=1` na execução do Terraform para garantir que o Proxmox processe um clone por vez, respeitando a fila de I/O do ZFS.

### 2. Timeout de I/O no Storage ZFS
**O Problema:** O processo de *Full Clone* em discos RAW sobre ZFS gera um pico de escrita que pode travar a comunicação da API (Erro 596 Connection Timeout).

**A Solução:**
* Configuração de `retries = 5` no bloco de clone do Terraform.
* Ajuste do `file_format = "raw"` para compatibilidade nativa com datasets ZFS, reduzindo o overhead de emulação.

---
---

## 🛠️ Guia de Solução de Problemas (Troubleshooting)
Durante a jornada de automação, documentamos cada erro de percurso — desde conflitos de IDs órfãos no Proxmox até crises de identidade entre os serviços Master e Worker. 

Se encontrar erros de `connection refused` ou falhas de clone, consulte o nosso guia detalhado:

👉 [**Acesse o TROUBLESHOOTING.md**](./TROUBLESHOOTING.md)

---
## 📂 Estrutura do Repositório

* `terraform/`: Contém os manifestos para provisionar as VMs no Proxmox via IaC.
* `scripts/`: Automações em shell para agilizar a configuração dos nós.
* `docs/`: Documentação técnica e diagramas de arquitetura.

## Como Executar

1. **Prepare o Template:** Tenha um template Cloud-Init (Debian/Ubuntu) com o ID `9000`.
2. **Configure as Variáveis:** Renomeie o arquivo `terraform.tfvars.example` para `terraform.tfvars` e insira suas credenciais.
3. **Aplique com cautela (Modo Estável):**
   ```bash
   terraform init
   terraform apply -parallelism=1 -auto-approve
   ```

---
**Davidson - DevOps & Infrastructure Learner**
