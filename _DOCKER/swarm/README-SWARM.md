# Docker Swarm - Guía de Despliegue

## Estructura de Archivos

```
wordpress-cluster/
├── services/                    (ya existe)
│   ├── wordpress/
│   ├── mysql/
│   ├── phpmyadmin/
│   ├── uptime-kuma/
│   ├── mailhog/
│   └── wp-cli/
├── scripts/                     (ya existe)
│   └── wp-init.sh
├── swarm/                       <- CREAR ESTA CARPETA
│   ├── docker-compose.swarm.yml
│   ├── deploy.sh
│   └── README-SWARM.md (este archivo)
├── .env
├── docker-compose.yml
└── README.md
```

## Preparación

### 1. Crear carpeta swarm

```bash
# Desde wordpress-cluster/
mkdir swarm
cd swarm
```

### 2. Copiar archivos

Copiar los siguientes archivos a la carpeta `swarm/`:
- `swarm-docker-compose.swarm.yml` → `docker-compose.swarm.yml`
- `swarm_cross-deploy.sh` → `deploy.sh`

### 3. Dar permisos de ejecución (Linux/Mac)

```bash
chmod +x deploy.sh
```

## Opción 1: Script Automatizado

### Linux/Mac/WSL

```bash
cd swarm
./deploy.sh
```

### Windows (Git Bash)

```bash
cd swarm
bash deploy.sh
```

### Windows (PowerShell)

```powershell
cd swarm
wsl bash deploy.sh
```

## Opción 2: Comandos Manuales (Cross-Platform)

Ejecutar desde la carpeta `wordpress-cluster/`.

### Paso 1: Verificar imágenes construidas

```bash
docker images | grep wordpress
```

Debe mostrar:
```
wordpress-app          1.0.0
wordpress-mysql        1.0.0
wordpress-phpmyadmin   1.0.0
wordpress-uptime       1.0.0
wordpress-mailhog      1.0.0
wordpress-cli          1.0.0
```

Si faltan imágenes:

```bash
docker-compose build
```

### Paso 2: Inicializar Docker Swarm

```bash
docker swarm init
```

Verificar:

```bash
docker node ls
```

Debe mostrar:
```
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS
abc123... *                   docker-desktop   Ready     Active         Leader
```

### Paso 3: Crear Secrets

**Linux/Mac:**

```bash
echo "tu_password_root" | docker secret create mysql_root_password -
echo "tu_password_user" | docker secret create mysql_password -
echo "tu_password_admin" | docker secret create wp_admin_password -
```

**Windows PowerShell:**

```powershell
echo "tu_password_root" | docker secret create mysql_root_password -
echo "tu_password_user" | docker secret create mysql_password -
echo "tu_password_admin" | docker secret create wp_admin_password -
```

**Windows CMD:**

```cmd
echo tu_password_root | docker secret create mysql_root_password -
echo tu_password_user | docker secret create mysql_password -
echo tu_password_admin | docker secret create wp_admin_password -
```

Verificar secrets:

```bash
docker secret ls
```

Debe mostrar:
```
ID            NAME                  CREATED
abc123...     mysql_root_password   x seconds ago
def456...     mysql_password        x seconds ago
ghi789...     wp_admin_password     x seconds ago
```

### Paso 4: Desplegar Stack

```bash
cd swarm
docker stack deploy -c docker-compose.swarm.yml wordpress
```

Esperar 15-20 segundos para que los servicios inicien.

### Paso 5: Verificar Despliegue

**Ver servicios:**

```bash
docker stack services wordpress
```

Debe mostrar:
```
ID          NAME                   MODE        REPLICAS   IMAGE
abc...      wordpress_mysql        replicated  1/1        wordpress-mysql:1.0.0
def...      wordpress_wordpress    replicated  3/3        wordpress-app:1.0.0
ghi...      wordpress_phpmyadmin   replicated  2/2        wordpress-phpmyadmin:1.0.0
...
```

**Ver tareas:**

```bash
docker stack ps wordpress
```

**Ver logs:**

```bash
docker service logs wordpress_wordpress
docker service logs wordpress_mysql
docker service logs wordpress_wp-cli
```

### Paso 6: Acceder a Servicios

- WordPress: http://localhost
- phpMyAdmin: http://localhost:8080
- Uptime Kuma: http://localhost:3001
- MailHog: http://localhost:8025

## Pruebas

### Test 1: Verificar réplicas de WordPress

```bash
docker service ps wordpress_wordpress
```

Debe mostrar 3 tareas corriendo.

### Test 2: Escalar WordPress

```bash
docker service scale wordpress_wordpress=5
```

Verificar:

```bash
docker service ps wordpress_wordpress
```

Debe mostrar 5 tareas corriendo.

Regresar a 3:

```bash
docker service scale wordpress_wordpress=3
```

### Test 3: Ver logs en tiempo real

```bash
docker service logs -f wordpress_wordpress
```

Hacer requests a http://localhost y ver los logs aparecer.

### Test 4: Simular falla de contenedor

```bash
# Listar contenedores de WordPress
docker ps | grep wordpress_wordpress

# Matar uno
docker kill <CONTAINER_ID>

# Ver que Swarm lo reinicia automáticamente
docker service ps wordpress_wordpress
```

Debe mostrar que Swarm detectó la falla y reinició el contenedor.

### Test 5: Load Balancing

Abrir http://localhost varias veces seguidas y verificar en logs que diferentes réplicas atienden las peticiones.

### Test 6: Rolling Update

```bash
# Forzar actualización (sin cambiar imagen)
docker service update --force wordpress_wordpress

# Ver actualización en progreso
docker service ps wordpress_wordpress
```

Swarm actualiza una réplica a la vez con 10s de delay (configurado en docker-compose.swarm.yml).

### Test 7: Inspeccionar secrets

```bash
docker secret inspect mysql_password
```

Muestra metadata pero NO el contenido del secret (encriptado).

### Test 8: Inspeccionar configs

```bash
docker config ls
docker config inspect wordpress_nginx_config
```

## Gestión del Stack

### Ver todos los servicios

```bash
docker stack services wordpress
```

### Ver todas las tareas

```bash
docker stack ps wordpress
```

### Actualizar servicio

```bash
docker service update --image wordpress-app:2.0.0 wordpress_wordpress
```

### Rollback servicio

```bash
docker service rollback wordpress_wordpress
```

### Eliminar stack completo

```bash
docker stack rm wordpress
```

Verificar que se eliminó:

```bash
docker stack ls
docker service ls
```

### Limpiar secrets

```bash
docker secret rm mysql_root_password mysql_password wp_admin_password
```

### Salir de Swarm

```bash
docker swarm leave --force
```

## Troubleshooting

### Error: "docker swarm init" falla

Si tienes múltiples interfaces de red:

```bash
docker swarm init --advertise-addr <IP_ADDRESS>
```

Obtener IP:

**Linux/Mac:**
```bash
ip addr show
```

**Windows:**
```powershell
ipconfig
```

### Error: Servicios en estado "Pending"

```bash
docker service ps wordpress_wordpress --no-trunc
```

Ver la razón exacta del pending.

Causas comunes:
- Imagen no existe localmente
- Secret no existe
- Config no existe

### Error: No puedo crear secrets

Verificar que Swarm está activo:

```bash
docker info | grep Swarm
```

Debe mostrar: `Swarm: active`

Si no, inicializar Swarm primero.

### Error: Stack no despliega

Verificar que estás en la carpeta correcta:

```bash
pwd  # Debe mostrar: /ruta/wordpress-cluster/swarm
ls   # Debe mostrar: docker-compose.swarm.yml
```

Verificar que archivos de config existen:

```bash
ls ../services/wordpress/nginx.conf
ls ../services/wordpress/php.ini
```

### WordPress no carga

```bash
# Ver logs
docker service logs wordpress_wordpress

# Ver tareas fallidas
docker service ps wordpress_wordpress --no-trunc

# Verificar conexión a MySQL
docker service ps wordpress_mysql
```

## Diferencias con Docker Compose

| Comando | Docker Compose | Docker Swarm |
|---------|----------------|--------------|
| Iniciar | `docker-compose up -d` | `docker stack deploy -c file.yml name` |
| Listar | `docker-compose ps` | `docker stack services name` |
| Logs | `docker-compose logs` | `docker service logs name_service` |
| Escalar | `docker-compose up -d --scale` | `docker service scale name_service=X` |
| Detener | `docker-compose down` | `docker stack rm name` |
| Ver config | `docker-compose config` | `docker stack config` |

## Comandos Rápidos

```bash
# Swarm
docker swarm init
docker node ls
docker swarm leave --force

# Secrets
docker secret create nombre -
docker secret ls
docker secret rm nombre

# Stack
docker stack deploy -c docker-compose.swarm.yml nombre
docker stack ls
docker stack services nombre
docker stack ps nombre
docker stack rm nombre

# Service
docker service ls
docker service ps nombre_servicio
docker service logs nombre_servicio
docker service scale nombre_servicio=N
docker service update --image imagen:tag nombre_servicio
docker service rollback nombre_servicio
```

## Validación Final

Checklist antes de considerar FASE 3 completa:

- [ ] Swarm inicializado: `docker node ls`
- [ ] Secrets creados: `docker secret ls` (3 secrets)
- [ ] Stack desplegado: `docker stack services wordpress` (6 servicios)
- [ ] WordPress con 3 réplicas corriendo
- [ ] phpMyAdmin con 2 réplicas corriendo
- [ ] WordPress accesible en http://localhost
- [ ] phpMyAdmin accesible en http://localhost:8080
- [ ] Uptime Kuma accesible en http://localhost:3001
- [ ] MailHog accesible en http://localhost:8025
- [ ] Escalar WordPress funciona
- [ ] Logs sin errores críticos
- [ ] Load balancing funciona (múltiples requests van a diferentes réplicas)

## Capturas Requeridas para Documentación

1. `docker node ls` - Mostrar Swarm activo
2. `docker secret ls` - Mostrar secrets creados
3. `docker stack services wordpress` - Mostrar servicios corriendo
4. `docker stack ps wordpress` - Mostrar tareas
5. `docker service ps wordpress_wordpress` - Mostrar 3 réplicas
6. Screenshot de WordPress funcionando
7. Screenshot de phpMyAdmin conectado a MySQL
8. `docker service logs wordpress_wordpress` - Logs sin errores
9. `docker service scale wordpress_wordpress=5` - Escalado funcional
10. Screenshot de load balancing (logs de diferentes réplicas)
