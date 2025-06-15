#!/bin/bash
# Despliegue de Mastodon en Terraform

# Verificar compatibilidad del SO
if ! grep -qi "ubuntu" /etc/os-release; then
    echo "Este script está diseñado solo para sistemas Ubuntu."
    exit 1
fi

# Habilitar el modo estricto
set -euo pipefail

# Registrar toda la salida en un archivo
exec > >(tee -i /var/log/mastodon_install.log)
exec 2>&1

# Captura de errores
trap 'echo "Ocurrio un error en la linea $LINENO"; exit 1' ERR

echo "Iniciando el despliegue de Mastodon..."

# 1. Actualizar paquetes e instalar dependencias
apt-get update -y
apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg lsb-release

# Añadir la clave GPG de Docker
echo "Verificando que la clave GPG de Docker este presente..."
DOCKER_GPG_PATH="/etc/apt/keyrings/docker.gpg"

mkdir -p /etc/apt/keyrings

if [ ! -f "$DOCKER_GPG_PATH" ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "$DOCKER_GPG_PATH"
  echo "Clave GPG de Docker instalada."
else
  echo "La clave GPG de Docker ya existe en $DOCKER_GPG_PATH — omitiendo."
fi

# Instalar el plugin de Docker Compose
apt-get update -y
apt-get install -y docker-compose-plugin

# Suprimir mensajes de reinicio
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
echo '* libraries/restart-without-asking boolean true' | debconf-set-selections

# Instalar Node.js y Ruby
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs ruby-full build-essential zlib1g-dev

# Configuracion de Docker
systemctl enable docker
systemctl start docker

echo "Versions:"
docker --version
docker compose version
node --version
npm --version

# 2. Clonar Mastodon
APP_DIR="/home/ubuntu/mastodon"
echo "Cloning Mastodon source into $APP_DIR..."
git clone https://github.com/mastodon/mastodon.git "$APP_DIR"
cd "$APP_DIR"
git checkout v4.3.8

# # Corregir los puertos de Docker Compose para que el ALB pueda acceder al contenedor externamente
# sed -i 's/127.0.0.1:3000:3000/3000:3000/' docker-compose.yml
# sed -i 's/127.0.0.1:4000:4000/4000:4000/' docker-compose.yml

# echo "Injecting PORT=4000 into streaming service..."
# sed -i '/streaming:/,/depends_on:/ s/^\( *\)depends_on:/\1environment:\n\1  PORT: 4000\n\1depends_on:/' docker-compose.yml

# Reemplazar docker-compose.yml con la version completamente actualizada
cat > docker-compose.yml << 'EOF'
# This file is designed for production server deployment, not local development work
# For a containerized local dev environment, see: https://github.com/mastodon/mastodon/blob/main/README.md#docker

services:
  db:
    restart: always
    image: postgres:14-alpine
    shm_size: 256mb
    networks:
      - internal_network
    healthcheck:
      test: ['CMD', 'pg_isready', '-U', 'postgres']
    volumes:
      - ./postgres14:/var/lib/postgresql/data
    environment:
      - 'POSTGRES_HOST_AUTH_METHOD=trust'

  redis:
    restart: always
    image: redis:7-alpine
    networks:
      - internal_network
    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
    volumes:
      - ./redis:/data

  web:
    # You can uncomment the following line if you want to not use the prebuilt image, for example if you have local code changes
    # build: .
    image: ghcr.io/mastodon/mastodon:v4.3.8
    restart: always
    env_file: .env.production
    command: bundle exec puma -C config/puma.rb
    networks:
      - external_network
      - internal_network
    healthcheck:
      # prettier-ignore
      test: ['CMD-SHELL',"curl -s --noproxy localhost localhost:3000/health | grep -q 'OK' || exit 1"]
    ports:
      - '3000:3000'
    depends_on:
      - db
      - redis
      # - es
    volumes:
      - ./public/system:/mastodon/public/system
      - ./.env.production:/mastodon/.env.production

  streaming:
    # You can uncomment the following lines if you want to not use the prebuilt image, for example if you have local code changes
    # build:
    #   dockerfile: ./streaming/Dockerfile
    #   context: .
    image: ghcr.io/mastodon/mastodon-streaming:v4.3.8
    restart: always
    env_file: .env.production
    command: node ./streaming/index.js
    networks:
      - external_network
      - internal_network
    healthcheck:
      # prettier-ignore
      test: ['CMD-SHELL', "curl -s --noproxy localhost localhost:4000/api/v1/streaming/health | grep -q 'OK' || exit 1"]
    ports:
      - '4000:4000'
    environment:
      PORT: 4000
    depends_on:
      - db
      - redis
    volumes:
      - ./.env.production:/mastodon/.env.production

  sidekiq:
    # You can uncomment the following line if you want to not use the prebuilt image, for example if you have local code changes
    # build: .
    image: ghcr.io/mastodon/mastodon:v4.3.8
    restart: always
    env_file: .env.production
    command: bundle exec sidekiq
    depends_on:
      - db
      - redis
    networks:
      - external_network
      - internal_network
    volumes:
      - ./public/system:/mastodon/public/system
      - ./.env.production:/mastodon/.env.production
    healthcheck:
      test: ['CMD-SHELL', "ps aux | grep '[s]idekiq\ 6' || false"]

networks:
  external_network:
  internal_network:
    internal: true
EOF

# 3. Configuracion del entorno
export RAILS_ENV=production

# Variables personalizables
# Cambia estos valores según los outputs
DOMAIN_NAME="ENDPOINT_ALB"
DB_HOST="RDS_ENDPOINT"  
DB_PORT="5432"
DB_NAME="NOMBRE_BD"
DB_USER="USUARIO_BD"
DB_PASS="PASSWORD_BD"

# Generar secretos
SECRET_KEY_BASE=$(openssl rand -hex 64)
OTP_SECRET=$(openssl rand -hex 64)
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=$(openssl rand -hex 32)
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=$(openssl rand -hex 32)
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=$(openssl rand -hex 32)

# Crear .env.production
cat > .env.production << EOF
LOCAL_DOMAIN=$DOMAIN_NAME
WEB_DOMAIN=$DOMAIN_NAME

RAILS_ENV=production
NODE_ENV=production
LOCAL_HTTPS=true
TRUST_PROXY=true

PORT=3000
BIND=0.0.0.0

DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_NAME=$DB_NAME
DB_PASS=$DB_PASS
DB_PORT=$DB_PORT

REDIS_HOST=redis
REDIS_PORT=6379

SECRET_KEY_BASE=$SECRET_KEY_BASE
OTP_SECRET=$OTP_SECRET

ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=$ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=$ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=$ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT

SMTP_SERVER=smtp.eu.mailgun.org
SMTP_PORT=587
SMTP_LOGIN=notifications@srestrepoj-mastodon.com
SMTP_PASSWORD=PASSWORD_SMTP
SMTP_FROM_ADDRESS=notifications@srestrepoj-mastodon.com
SMTP_DOMAIN=srestrepoj-mastodon.com

RAILS_SERVE_STATIC_FILES=true
EOF

# 4. Precrear directorios de datos
mkdir -p ./public/system ./public/assets ./public/packs ./redis
chown -R 991:991 ./public
chmod -R u+rw ./public

# 5. Iniciar Redis primero
docker compose up -d redis
echo "Waiting for Redis..."
sleep 10

# 6. Generar llaves VAPID
docker compose run --rm web bundle exec rake mastodon:webpush:generate_vapid_key > vapid_keys.txt
VAPID_PRIVATE_KEY=$(grep VAPID_PRIVATE_KEY vapid_keys.txt | cut -d '=' -f2 | tr -d ' ')
VAPID_PUBLIC_KEY=$(grep VAPID_PUBLIC_KEY vapid_keys.txt | cut -d '=' -f2 | tr -d ' ')
rm vapid_keys.txt

# Agregar llaves VAPID
cat >> .env.production << EOF

VAPID_PRIVATE_KEY=$VAPID_PRIVATE_KEY
VAPID_PUBLIC_KEY=$VAPID_PUBLIC_KEY
EOF

# 7. Descargar todas las imagenes
docker compose pull

# 8. Migracion de base de datos
docker compose run --rm web bundle exec rake db:migrate

# 9. Iniciar todos los contenedores
docker compose up -d

# 10. Verificar estado
docker compose ps

echo "Despliegue de Mastodon completado con exito!"
