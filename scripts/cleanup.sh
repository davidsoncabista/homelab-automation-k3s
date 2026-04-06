#!/bin/bash
# Script para limpar o node e começar do zero
echo "Removendo K3s..."
/usr/local/bin/k3s-uninstall.sh || /usr/local/bin/k3s-agent-uninstall.sh
echo "Limpeza concluída!"
