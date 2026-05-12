# Deploy

Esta carpeta contiene la configuración necesaria para ejecutar la plataforma en ambientes locales y de despliegue.

## Contenido

- `docker-compose.yml` para levantar frontend, APIs y base de datos.
- Configuración de Nginx como punto de entrada público.
- Scripts operativos para despliegue en EC2, si son necesarios.

## Variables de entorno

Crear un archivo `.env` a partir del ejemplo:

```bash
copy deploy\.env.example deploy\.env
```

En PowerShell también puede usarse:

```powershell
Copy-Item deploy\.env.example deploy\.env
```

El archivo `.env` contiene las variables utilizadas por MySQL y por los servicios Spring Boot:

```text
MYSQL_ROOT_PASSWORD
MYSQL_DATABASE
DB_ENDPOINT
DB_PORT
DB_NAME
DB_USERNAME
DB_PASSWORD
```

## Levantar el stack

Desde la raíz del repositorio:

```bash
docker compose --env-file deploy/.env -f deploy/docker-compose.yml up -d --build
```

Si solo se quiere usar el archivo de ejemplo:

```bash
docker compose --env-file deploy/.env.example -f deploy/docker-compose.yml up -d --build
```

## URLs locales

- Frontend: `http://localhost`
- Healthcheck frontend: `http://localhost/health`
- API despachos directa: `http://localhost:8080/api/v1/despachos`
- API ventas directa: `http://localhost:8081/api/v1/ventas`
- API despachos vía Nginx: `http://localhost/api/v1/despachos`
- API ventas vía Nginx: `http://localhost/api/v1/ventas`

## Operación básica

Ver contenedores:

```bash
docker compose --env-file deploy/.env -f deploy/docker-compose.yml ps
```

Ver logs:

```bash
docker compose --env-file deploy/.env -f deploy/docker-compose.yml logs -f
```

Detener contenedores sin borrar datos:

```bash
docker compose --env-file deploy/.env -f deploy/docker-compose.yml down
```

Detener contenedores y borrar el volumen de MySQL:

```bash
docker compose --env-file deploy/.env -f deploy/docker-compose.yml down -v
```

## Persistencia

MySQL usa un named volume llamado `mysql_data`. Esto permite conservar los datos aunque los contenedores se detengan o se creen nuevamente. El volumen se elimina solo si se ejecuta `docker compose down -v`.
