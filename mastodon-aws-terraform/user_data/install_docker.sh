#!/bin/bash
set -e

# Instalar Docker si no esta instalado
if ! command -v docker &> /dev/null; then
  apt-get update -y
  apt-get install -y docker.io git curl
fi

# Instalar Docker Compose v2
echo "Installing Docker Compose v2 plugin ..."

# Instalar dependencias requeridas
apt-get install -y ca-certificates curl gnupg lsb-release

# Agregar la llave GPG oficial de Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg.new
mv -f /etc/apt/keyrings/docker.gpg.new /etc/apt/keyrings/docker.gpg

# Configurar el repositorio APT de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar apt e instalar docker-compose-plugin
apt-get update -y
apt-get install -y docker-compose-plugin

# Agregar el usuario 'ubuntu' al grupo Docker (solo si no esta agregado)
if ! groups ubuntu | grep -q "\bdocker\b"; then
  usermod -aG docker ubuntu
fi

# Habilitar e iniciar Docker
systemctl enable docker
systemctl start docker