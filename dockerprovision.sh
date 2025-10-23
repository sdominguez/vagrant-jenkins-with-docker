#!/usr/bin/env bash
set -euo pipefail

WORKDIR="/var/workspace/dockerjenkins"

echo "[1/5] Instalando dependencias del repositorio Docker..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release tree

echo "[2/5] Instalando Docker CE + Compose v2..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
   https://download.docker.com/linux/ubuntu \
   $(. /etc/os-release; echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
# docker-compose-plugin = "docker compose"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
                        docker-buildx-plugin docker-compose-plugin git

sudo systemctl enable --now docker

echo "[3/5] Añadiendo usuario 'vagrant' al grupo docker..."
if ! getent group docker >/dev/null; then
  sudo groupadd docker
fi
sudo usermod -aG docker vagrant

echo "[4/5] Preparando workspace en ${WORKDIR}..."
sudo mkdir -p "$WORKDIR"
sudo chown -R vagrant:vagrant "$WORKDIR"

# Detecta archivo de compose
COMPOSE_FILE=""
for f in "compose.yaml" "compose.yml" "docker-compose.yml"; do
  if [[ -f "${WORKDIR}/${f}" ]]; then
    COMPOSE_FILE="${WORKDIR}/${f}"
    break
  fi
done

echo "[5/5] Lanzando docker compose (para Jenkins)..."

if [[ -n "${COMPOSE_FILE}" ]]; then
  # obtiene el GID del grupo docker del host/VM
  DOCKER_GID=$(getent group docker | cut -d: -f3 || echo "")
  if [[ -z "${DOCKER_GID}" ]]; then
    echo "No se pudo obtener DOCKER_GID, se continuará sin exportarlo."
  else
    echo "DOCKER_GID detectado: ${DOCKER_GID}"
  fi

  echo "→ Ejecutando docker compose dentro de ${WORKDIR}"
  sudo -H -u vagrant -g docker env HOME=/home/vagrant DOCKER_CONFIG=/home/vagrant/.docker DOCKER_GID="${DOCKER_GID}" bash -lc "
    cd '${WORKDIR}' && \
    docker compose -f '${COMPOSE_FILE}' up -d --build
  "
else
  echo "No se encontró compose.yaml/yml en ${WORKDIR}. Omitiendo 'docker compose up'."
fi

echo
docker --version
docker compose version || true
echo "Aprovisionamiento completado."