# Jenkins en Vagrant con Docker (Docker-in-Docker)

Este proyecto crea una **máquina virtual provisionada automáticamente con Docker y Jenkins** usando **Vagrant**.  
El contenedor de Jenkins está configurado con acceso al **demonio Docker del host (Docker-in-Docker)**, permitiendo ejecutar *builds* y despliegues directamente desde Jenkins.

---

## Objetivo

Automatizar la creación de un entorno local de CI/CD con:

- Una VM en **Vagrant + VirtualBox**
- **Docker** instalado dentro de la VM
- Un contenedor **Jenkins LTS** con **Docker CLI + Compose** preinstalados
- Acceso al socket de Docker del host para crear contenedores desde Jenkins

---

## Requisitos previos

Antes de comenzar, asegúrate de tener instalados:

| Herramienta | Descripción | Enlace |
|--------------|-------------|--------|
| [Vagrant](https://developer.hashicorp.com/vagrant/downloads) | Herramienta para crear entornos virtuales reproducibles | |
| [VirtualBox](https://www.virtualbox.org/wiki/Downloads) | Proveedor de virtualización para Vagrant | |
| [Git](https://git-scm.com/downloads) *(opcional)* | Para clonar este repositorio | |

---

## ⚙️ Estructura del proyecto

```
.
├── Vagrantfile
├── dockerprovision.sh       
workspace/dockerjenkins
   ├── docker-compose.yml        
   └── Dockerfile                
└──README.md
```

---

## Instalación paso a paso

1. **Clona o copia** el repositorio:
   ```bash
   git clone https://github.com/usuario/jenkins-vagrant-docker.git
   cd jenkins-vagrant-docker
   ```

2. **Levanta la VM**:
   ```bash
   vagrant up
   ```

3. **Accede a Jenkins**:
   Una vez que el aprovisionamiento termine, abre tu navegador en:
   ```
   http://localhost:8080
   ```

4. **Obtén la clave inicial de Jenkins (solo en la primera ejecución)**:
   ```bash
   vagrant ssh
   sudo cat /var/lib/docker/volumes/dockerjenkins_jenkins_home/_data/secrets/initialAdminPassword
   ```

---

## Instalación de Guest Additions (si es necesario)

Las **Guest Additions** de VirtualBox mejoran la sincronización y el rendimiento de carpetas compartidas entre host y VM.

1. Instala el plugin en tu máquina anfitriona:
   ```bash
   vagrant plugin install vagrant-vbguest
   ```

2. Reinicia la VM:
   ```bash
   vagrant reload
   ```

---

## Limpieza

Para eliminar la VM:

```bash
vagrant destroy -f
vagrant box prune
```


---

## Comandos útiles

| Acción | Comando |
|--------|----------|
| Crear y aprovisionar VM | `vagrant up` |
| Acceder a la VM | `vagrant ssh` |
| Detener la VM | `vagrant halt` |
| Eliminar la VM | `vagrant destroy -f` |
| Ver estado global | `vagrant global-status --prune` |

---

## Notas finales

- Jenkins se ejecuta en el puerto **8080**, con el agente JNLP en el **50000**.
- El contenedor de Jenkins tiene acceso al socket `/var/run/docker.sock` del host.
- Si quieres reiniciar Jenkins desde cero, elimina el volumen:
  ```bash
  docker compose down -v
  ```
