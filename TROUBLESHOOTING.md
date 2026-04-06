# 🛠 Registro de Desafios e Soluções - K3s on Proxmox

Este documento registra os problemas técnicos enfrentados durante o provisionamento do cluster e as respectivas soluções aplicadas.

## 1. Conflito de ID de VM no Proxmox (HTTP 500)
**Sintoma:** O Terraform falha ao criar a VM com o erro: `unable to create VM 1201: config file already exists`.
**Causa:** Tentativas anteriores de `terraform apply` deixaram arquivos de configuração órfãos no storage do Proxmox, mesmo que a VM não aparecesse na interface gráfica.
**Solução:** 1. Remover manualmente a VM ou o arquivo de configuração em `/etc/pve/qmu-server/[ID].conf` no host Proxmox.
2. Rodar `terraform apply` novamente sem apagar o `.tfstate` para que ele identifique os recursos já existentes (1202, 1203).

## 2. Incompatibilidade do Provider Proxmox (PVE 9)
**Sintoma:** Erros de permissão e falha na comunicação com a API usando o provider `telmate/proxmox`.
**Causa:** O Proxmox 9 introduziu mudanças nas camadas de autenticação e API que quebram a compatibilidade com providers legados.
**Solução:** Migração para o provider `bpg/proxmox`, que oferece suporte nativo às chamadas de API mais recentes e melhor integração com Cloud-Init.

## 3. Conflito de Funções (Server vs Agent)
**Sintoma:** Erro `connection refused` ao rodar `kubectl get nodes` e falha no serviço `k3s-agent.service`.
**Causa:** O script de instalação do K3s Agent foi executado por engano no nó Master (131). Isso sobrescreveu as configurações do Server e tentou subir um processo de Agent onde já deveria existir um Server.
**Solução:**
1. Rodar o script de desinstalação do agente: `/usr/local/bin/k3s-agent-uninstall.sh`.
2. Reinstalar o modo Server: `curl -sfL https://get.k3s.io | sh -s - server ...`.
3. Reiniciar o serviço para forçar o carregamento: `systemctl restart k3s`.

## 4. Otimização de Storage ZFS
**Sintoma:** Lentidão ou erro de "config file already exists" devido ao comportamento de escrita do ZFS.
**Solução:** Garantir que o `datastore_id` no Terraform esteja apontando para o pool correto (`VMs-Disck` para discos e `local-zfs` para Cloud-Init/Snippets).
