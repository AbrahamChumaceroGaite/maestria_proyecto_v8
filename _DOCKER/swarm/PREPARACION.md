# SWARM - Preparación Inicial

## Estructura Final del Proyecto

```
wordpress-cluster/
├── .dockerignore
├── .env
├── .env.example
├── docker-compose.yml
├── README.md
├── services/
│   ├── wordpress/
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   └── php.ini
│   ├── mysql/
│   │   ├── Dockerfile
│   │   └── init.sql
│   ├── phpmyadmin/
│   │   └── Dockerfile
│   ├── uptime-kuma/
│   │   └── Dockerfile
│   ├── mailhog/
│   │   └── Dockerfile
│   └── wp-cli/
│       └── Dockerfile
├── scripts/
│   └── wp-init.sh
└── swarm/                              <- CREAR ESTA CARPETA
    ├── docker-compose.swarm.yml        <- Archivo del stack
    ├── deploy.sh                       <- Script de despliegue
    └── README-SWARM.md                 <- Instrucciones
```

## Pasos Iniciales (ANTES de Swarm)

### 1. Verificar que FASE 2 funciona

```bash
cd wordpress-cluster
docker-compose up -d
```

Verificar que todos los servicios están UP:

```bash
docker-compose ps
```

Acceder a:
- http://localhost (WordPress)
- http://localhost:8080 (phpMyAdmin)

Si todo funciona, continuar. Si no, arreglar FASE 2 primero.

### 2. Detener Docker Compose

```bash
docker-compose down
```

NO eliminar volúmenes (mantener datos).

### 3. Verificar imágenes construidas

```bash
docker images | grep wordpress
```

Debe mostrar 6 imágenes con tag 1.0.0:
- wordpress-app:1.0.0
- wordpress-mysql:1.0.0
- wordpress-phpmyadmin:1.0.0
- wordpress-uptime:1.0.0
- wordpress-mailhog:1.0.0
- wordpress-cli:1.0.0

### 4. Crear carpeta swarm

```bash
mkdir swarm
cd swarm
```

### 5. Copiar archivos de Swarm

Copiar los siguientes archivos descargados a la carpeta `swarm/`:

**Renombrar al copiar:**

```bash
# Desde la ubicación de descarga
cp swarm-docker-compose.swarm.yml wordpress-cluster/swarm/docker-compose.swarm.yml
cp swarm_cross-deploy.sh wordpress-cluster/swarm/deploy.sh
cp swarm_cross-README-SWARM.md wordpress-cluster/swarm/README-SWARM.md
```

### 6. Dar permisos de ejecución (Linux/Mac/WSL)

```bash
cd wordpress-cluster/swarm
chmod +x deploy.sh
```

## Despliegue en Swarm

### Opción A: Script Automatizado

**Linux/Mac/WSL:**

```bash
cd wordpress-cluster/swarm
./deploy.sh
```

**Windows (Git Bash incluido con Git):**

```bash
cd wordpress-cluster/swarm
bash deploy.sh
```

**Windows (desde PowerShell con WSL instalado):**

```powershell
cd wordpress-cluster\swarm
wsl bash deploy.sh
```

El script ejecutará:
1. Inicializar Swarm
2. Solicitar passwords para secrets
3. Crear secrets
4. Verificar imágenes
5. Desplegar stack
6. Mostrar servicios corriendo

### Opción B: Comandos Manuales

Ver archivo `README-SWARM.md` en la carpeta `swarm/` para comandos paso a paso.

## Comandos Esenciales

Todos ejecutados desde `wordpress-cluster/swarm/`:

```bash
# Inicializar Swarm
docker swarm init

# Crear secrets
echo "password" | docker secret create mysql_root_password -
echo "password" | docker secret create mysql_password -
echo "password" | docker secret create wp_admin_password -

# Desplegar stack
docker stack deploy -c docker-compose.swarm.yml wordpress

# Ver servicios
docker stack services wordpress

# Ver logs
docker service logs wordpress_wordpress

# Eliminar stack
docker stack rm wordpress

# Salir de Swarm
docker swarm leave --force
```

## Verificación Rápida

```bash
# 1. Swarm activo
docker node ls

# 2. Secrets creados
docker secret ls

# 3. Stack desplegado
docker stack services wordpress

# 4. WordPress funciona
curl http://localhost
```

## Solución de Problemas Comunes

### "docker swarm init" falla

Si tienes múltiples interfaces de red, especifica la IP:

```bash
docker swarm init --advertise-addr 192.168.x.x
```

### Script deploy.sh no ejecuta en Windows

Opciones:

1. Usar Git Bash: `bash deploy.sh`
2. Usar WSL: `wsl bash deploy.sh`
3. Ejecutar comandos manualmente (ver README-SWARM.md)

### Imágenes no existen

Volver a FASE 2 y construir:

```bash
cd wordpress-cluster
docker-compose build
```

### Stack no despliega

Verificar que estás en la carpeta correcta:

```bash
pwd  # Debe mostrar: .../wordpress-cluster/swarm
ls   # Debe mostrar: docker-compose.swarm.yml
```

Verificar rutas en docker-compose.swarm.yml:

```yaml
configs:
  nginx_config:
    file: ../services/wordpress/nginx.conf  # Ruta relativa correcta
```

### No puedo acceder a WordPress

Verificar que los servicios están corriendo:

```bash
docker stack services wordpress
```

Ver logs:

```bash
docker service logs wordpress_wordpress
docker service logs wordpress_mysql
```

## Diferencias Clave vs Docker Compose

1. **Comando de inicio:**
   - Compose: `docker-compose up -d`
   - Swarm: `docker stack deploy -c file.yml name`

2. **Variables de entorno:**
   - Compose: Archivo `.env`
   - Swarm: Secrets encriptados

3. **Archivos de configuración:**
   - Compose: COPY en Dockerfile
   - Swarm: Configs en runtime

4. **Escalado:**
   - Compose: `docker-compose up -d --scale service=N`
   - Swarm: `docker service scale service=N`

5. **Logs:**
   - Compose: `docker-compose logs service`
   - Swarm: `docker service logs stack_service`

## Próximos Pasos

Una vez que Swarm funcione correctamente:

1. Tomar capturas de pantalla para documentación
2. Probar escalado de servicios
3. Probar rolling updates
4. Probar rollback
5. Documentar todo en README final

Luego continuar con FASE 4: Kubernetes
