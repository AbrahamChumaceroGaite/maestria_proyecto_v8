# WordPress Cluster con Docker

Sistema de contenedores Docker para WordPress con base de datos MySQL, phpMyAdmin, monitoreo con Uptime Kuma y servidor SMTP de testing con MailHog.

## Arquitectura

```
wordpress-cluster/
├── services/
│   ├── wordpress/      - WordPress con Nginx y PHP-FPM
│   ├── mysql/          - MySQL 8.0
│   ├── phpmyadmin/     - Interfaz web para MySQL
│   ├── uptime-kuma/    - Sistema de monitoreo
│   ├── mailhog/        - Servidor SMTP de testing
│   └── wp-cli/         - Herramienta CLI para WordPress
├── scripts/
│   └── wp-init.sh      - Script de inicialización automática
├── .env                - Variables de entorno
├── .dockerignore       - Exclusiones de build
└── docker-compose.yml  - Definición de servicios
```

## Servicios

| Servicio | Puerto | Función |
|----------|--------|---------|
| WordPress | 80 | CMS principal |
| phpMyAdmin | 8080 | Gestión de base de datos |
| Uptime Kuma | 3001 | Monitoreo de servicios |
| MailHog Web | 8025 | Interfaz de emails |
| MailHog SMTP | 1025 | Servidor SMTP interno |
| MySQL | 3306 | Base de datos (no expuesto) |

## Requisitos

- Docker Desktop instalado y ejecutándose
- Windows 10/11 Pro con WSL2 habilitado
- Mínimo 4GB RAM asignados a Docker
- Puerto 80, 8080, 3001, 8025 disponibles

## Instalación

### Clonar estructura de carpetas

```powershell
mkdir wordpress-cluster
cd wordpress-cluster
mkdir services scripts
mkdir services\wordpress services\mysql services\phpmyadmin services\uptime-kuma services\mailhog services\wp-cli
```

### Configurar variables de entorno

Copiar `.env.example` a `.env` y modificar las contraseñas:

```bash
MYSQL_ROOT_PASSWORD=password_root_seguro
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=password_user_seguro

WORDPRESS_DB_HOST=mysql:3306
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=password_user_seguro
WORDPRESS_TABLE_PREFIX=wp_

PMA_HOST=mysql
PMA_PORT=3306

WORDPRESS_URL=http://localhost
WORDPRESS_TITLE=WordPress Cluster Demo
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=admin123
WORDPRESS_ADMIN_EMAIL=admin@example.com

SMTP_HOST=mailhog
SMTP_PORT=1025
```

### Construir y ejecutar

```powershell
docker-compose build
docker-compose up -d
```

### Verificar servicios

```powershell
docker-compose ps
```

Todos los servicios deben mostrar estado "Up".

## Configuración de WordPress

### Límites de subida

- Tamaño máximo de archivo: 100MB
- Límite de memoria PHP: 256MB
- Tiempo máximo de ejecución: 300 segundos

Configurado en `services/wordpress/php.ini`:

```ini
upload_max_filesize = 100M
post_max_size = 100M
memory_limit = 256M
max_execution_time = 300
```

### Inicialización automática

El servicio `wp-cli` ejecuta automáticamente:

1. Creación de archivo `wp-config.php`
2. Instalación de WordPress
3. Creación de 2 posts de prueba
4. Creación de usuarios: editor y author

Credenciales creadas:

- admin / admin123
- editor / editor123 (rol: Editor)
- author / author123 (rol: Author)

## Configuración de Email

### Instalar plugin WP Mail SMTP

```powershell
docker-compose run --rm wp-cli wp plugin install wp-mail-smtp --activate --allow-root
```

### Configuración manual en WordPress

1. Acceder a WP Mail SMTP → Settings
2. Configurar:
   - Mailer: Other SMTP
   - SMTP Host: mailhog
   - SMTP Port: 1025
   - Encryption: None
   - Authentication: OFF

3. Enviar email de prueba
4. Verificar en http://localhost:8025

## Redes

### Frontend (bridge)

Servicios expuestos al host:
- wordpress
- phpmyadmin
- uptime-kuma

### Backend (bridge)

Red interna sin exposición al host:
- mysql
- mailhog
- wp-cli

## Volúmenes

Datos persistentes:

```yaml
mysql-data:         /var/lib/mysql
wordpress-data:     /var/www/html
uptime-data:        /app/data
```

Los datos persisten entre reinicios y recreaciones de contenedores.

## Comandos

### Gestión de servicios

```powershell
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose stop

# Ver logs
docker-compose logs -f

# Reiniciar servicio específico
docker-compose restart wordpress

# Eliminar servicios
docker-compose down

# Eliminar servicios y volúmenes
docker-compose down -v
```

### WordPress CLI

```powershell
# Listar plugins
docker-compose run --rm wp-cli wp plugin list --allow-root

# Listar temas
docker-compose run --rm wp-cli wp theme list --allow-root

# Crear post
docker-compose run --rm wp-cli wp post create --post_title="Titulo" --post_content="Contenido" --post_status=publish --allow-root

# Crear usuario
docker-compose run --rm wp-cli wp user create username email@example.com --role=author --user_pass=password --allow-root
```

### Base de datos

```powershell
# Backup
docker-compose exec mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} wordpress > backup.sql

# Restore
docker-compose exec -T mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress < backup.sql

# Acceder a MySQL CLI
docker-compose exec mysql mysql -u wpuser -p${MYSQL_PASSWORD} wordpress
```

## Troubleshooting

### WordPress no carga

```powershell
# Ver logs de WordPress
docker-compose logs wordpress

# Verificar conexión a MySQL
docker-compose exec wordpress ping mysql

# Reiniciar WordPress
docker-compose restart wordpress
```

### Error al subir archivos

```powershell
# Verificar permisos
docker-compose exec wordpress ls -la /var/www/html/wp-content

# Debe mostrar:
# drwxrwxr-x www-data www-data uploads
# drwxrwxr-x www-data www-data plugins
# drwxrwxr-x www-data www-data themes
```

### Limpiar y reconstruir

```powershell
# Detener y eliminar todo
docker-compose down -v --rmi all

# Limpiar sistema Docker
docker system prune -a -f

# Reconstruir desde cero
docker-compose up -d --build
```

### MySQL no inicia

```powershell
# Ver logs
docker-compose logs mysql

# Verificar healthcheck
docker inspect wp-mysql | findstr -i health

# Eliminar volumen corrupto
docker-compose down -v
docker-compose up -d
```

## Especificaciones Técnicas

### WordPress

- Base: PHP 8.2 FPM Alpine
- Servidor web: Nginx 1.28.0
- Extensiones PHP: mysqli, pdo, pdo_mysql, opcache
- OPcache: Habilitado
- Timezone: America/La_Paz

### MySQL

- Versión: 8.0 Debian
- Charset: utf8mb4
- Collation: utf8mb4_unicode_ci
- Healthcheck: mysqladmin ping

### phpMyAdmin

- Versión: 5 Apache
- Puerto interno: 80
- Conexión automática a MySQL

### Uptime Kuma

- Versión: 1 Alpine
- Almacenamiento: SQLite en volumen persistente

### MailHog

- Puerto SMTP: 1025
- Puerto Web UI: 8025
- Sin autenticación

## Seguridad

### Variables de entorno

Contraseñas y datos sensibles almacenados en archivo `.env`, no incluido en el repositorio.

### Red backend

MySQL y MailHog en red interna sin exposición al host.

### Permisos de archivos

```
/var/www/html:         755 (www-data:www-data)
/var/www/html/wp-content: 775 (www-data:www-data)
```

### Nginx

- Bloqueo de archivos .ht
- Bloqueo de ejecución PHP en uploads
- Headers de seguridad básicos

## Notas

### Desarrollo local

Este entorno está configurado para desarrollo y testing local. Para producción se requiere:

- HTTPS con certificados SSL
- Contraseñas seguras en secrets
- Configuración de firewall
- Backups automáticos
- Logging centralizado
- Monitoring avanzado

### Compatibilidad

Probado en:
- Windows 11 con Docker Desktop 4.x
- WSL2 backend
- Docker Compose v3.8

### Limitaciones

- Single-node: Un solo nodo Docker
- No load balancing
- No auto-scaling
- MailHog no persiste emails entre reinicios

## Próximos pasos

Para entornos de producción:

1. Migrar a Docker Swarm (multi-node, réplicas, secrets)
2. Implementar Kubernetes (orchestration avanzado)
3. Agregar reverse proxy con SSL (Traefik/Nginx Proxy)
4. Implementar CI/CD pipeline
5. Configurar backups automáticos
6. Agregar monitoring con Prometheus/Grafana