# Deploy

Esta carpeta contiene la configuracion necesaria para ejecutar la plataforma en ambientes locales y de despliegue.

## Contenido

- `docker-compose.yml` para levantar frontend, APIs y base de datos.
- Configuracion de Nginx como punto de entrada publico.
- Guia de despliegue manual en AWS ECS.

## Variables de entorno

Crear un archivo `.env` a partir del ejemplo:

```bash
copy deploy\.env.example deploy\.env
```

En PowerShell tambien puede usarse:

```powershell
Copy-Item deploy\.env.example deploy\.env
```

El archivo `.env` contiene las variables utilizadas por MySQL y por los servicios Spring Boot.

| Variable | Servicio | Descripcion |
| --- | --- | --- |
| `MYSQL_ROOT_PASSWORD` | MySQL | Password administrativo del contenedor MySQL. |
| `MYSQL_DATABASE` | MySQL | Base de datos creada al iniciar el contenedor. |
| `MYSQL_USER` | MySQL | Usuario de aplicacion creado al iniciar el contenedor. |
| `MYSQL_PASSWORD` | MySQL | Password del usuario de aplicacion. |
| `DB_ENDPOINT` | APIs | Host de la base de datos usado por Spring Boot. |
| `DB_PORT` | APIs | Puerto de conexion a MySQL. |
| `DB_NAME` | APIs | Nombre de la base de datos usada por las APIs. |
| `DB_USERNAME` | APIs | Usuario usado por las APIs para conectar a MySQL. |
| `DB_PASSWORD` | APIs | Password usado por las APIs para conectar a MySQL. |
| `SERVER_PORT` | APIs | Puerto interno definido por servicio en `docker-compose.yml`. |

## Levantar el stack

Desde la raiz del repositorio:

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
- API despachos via Nginx: `http://localhost/api/v1/despachos`
- API ventas via Nginx: `http://localhost/api/v1/ventas`

## Operacion basica

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

## AWS

El despliegue manual hacia AWS ECS esta documentado en `deploy/aws-ecs.md`.
