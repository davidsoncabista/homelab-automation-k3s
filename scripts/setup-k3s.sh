#!/bin/bash
# Automação de Instalação K3s - Homelab
GREEN='\033[0;32m'
NC='\033[0m'
TYPE=$1
MASTER_IP="192.168.0.131" # Altere para o seu IP de Master
NODE_TOKEN="SEU_TOKEN_AQUI" # Não esqueça de preencher localmente

echo -e "${GREEN}===> Iniciando instalação do K3s como: $TYPE${NC}"

if [ "$TYPE" == "server" ]; then
    curl -sfL https://get.k3s.io | sh -s - server --disable traefik --node-name master-01
elif [ "$TYPE" == "agent" ]; then
    curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=${NODE_TOKEN} sh -
else
    echo "Uso: ./setup-k3s.sh [server|agent]"
    exit 1
fi
echo -e "${GREEN}===> Instalação finalizada!${NC}"
