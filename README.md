# Innovatech Logistics Platform

Plataforma logística para Innovatech Chile orientada a la gestión de ventas y despachos. El proyecto se organiza como monorepo para centralizar frontend, servicios backend, infraestructura, despliegue y automatización CI/CD.

## Stack técnico

- React/Vite para el frontend.
- Spring Boot y Java 17 para los servicios backend.
- MySQL como base de datos relacional.
- Docker y Docker Compose para contenedorización.
- Terraform para infraestructura AWS.
- GitHub Actions para CI/CD.
- Amazon ECR para registro de imágenes.
- Amazon EC2, Amazon ECS, VPC y Security Groups para despliegue.

## Estructura

```text
innovatech-logistics-platform/
  apps/
    frontend-despachos/
    api-despachos/
    api-ventas/
  deploy/
    nginx/
  infra/
    terraform/
  .github/
    workflows/
  docs/
```

## Componentes

| Componente | Ruta | Tecnología | Puerto |
| --- | --- | --- | --- |
| Frontend despachos | `apps/frontend-despachos` | React/Vite + Nginx | `80` |
| API despachos | `apps/api-despachos` | Spring Boot + Java 17 | `8080` |
| API ventas | `apps/api-ventas` | Spring Boot + Java 17 | `8081` |
| Base de datos | `deploy/docker-compose.yml` | MySQL 8 | `3306` |

## Alcance DevOps

- Dockerfiles multi-stage por servicio.
- Ejecución de contenedores con usuario no root cuando corresponda.
- Stack local y de despliegue mediante Docker Compose.
- Persistencia de datos mediante volúmenes Docker para MySQL.
- Infraestructura AWS definida con Terraform.
- Pipeline CI/CD con GitHub Actions.
- Publicación de imágenes en Amazon ECR.
- Despliegue automatizado sobre AWS.
- Separación de acceso entre frontend público y servicios internos.

## Flujo de ramas

```text
feature/* -> develop -> main
```

- `main`: versión estable.
- `develop`: integración de cambios aprobados.
- `feature/*`: desarrollo por capacidad técnica.
- `deploy`: despliegue automatizado.
