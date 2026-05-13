# Innovatech Logistics Platform

Plataforma logistica para Innovatech Chile orientada a la gestion de ventas y despachos. El proyecto se organiza como monorepo para centralizar frontend, servicios backend, infraestructura, despliegue y automatizacion CI/CD.

## Arquitectura

La solucion se compone de una aplicacion frontend, dos servicios backend y una base de datos MySQL. En ambiente local se ejecuta con Docker Compose. En AWS se despliega con imagenes publicadas en Amazon ECR, ejecucion de contenedores en Amazon ECS Fargate, base de datos MySQL sobre EC2 y recursos de red administrados con Terraform.

```text
Usuario
  |
  v
Frontend Nginx / React
  |
  +--> API despachos -> MySQL
  |
  +--> API ventas ----> MySQL
```

## Stack tecnico

- React/Vite para el frontend.
- Spring Boot y Java 17 para los servicios backend.
- MySQL como base de datos relacional.
- Docker y Docker Compose para contenedorizacion local.
- Terraform para infraestructura AWS.
- GitHub Actions para CI/CD.
- Amazon ECR para registro de imagenes.
- Amazon ECS Fargate para ejecucion de contenedores.
- Amazon EC2 para runtime MySQL.
- VPC, subred publica, Security Groups y CloudWatch para red, seguridad y observabilidad.

## Estructura

```text
innovatech-logistics-platform/
  apps/
    frontend-despachos/
    api-despachos/
    api-ventas/
  deploy/
    docker-compose.yml
    aws-ecs.md
  infra/
    terraform/
  .github/
    workflows/
  docs/
```

## Componentes

| Componente | Ruta | Tecnologia | Puerto |
| --- | --- | --- | --- |
| Frontend despachos | `apps/frontend-despachos` | React/Vite + Nginx | `80` |
| API despachos | `apps/api-despachos` | Spring Boot + Java 17 | `8080` |
| API ventas | `apps/api-ventas` | Spring Boot + Java 17 | `8081` |
| Base de datos local | `deploy/docker-compose.yml` | MySQL 8.4 | `3306` |
| Infraestructura AWS | `infra/terraform` | Terraform + AWS Provider | N/A |

## Flujo DevOps

```text
feature/* -> develop -> deploy -> main
```

- `feature/*`: desarrollo por capacidad tecnica.
- `develop`: integracion de cambios aprobados.
- `deploy`: publicacion de imagenes y despliegue hacia AWS.
- `main`: version estable.

## Ejecucion local

La plataforma puede ejecutarse localmente con Docker Compose desde la configuracion ubicada en [deploy/README.md](deploy/README.md).

## Infraestructura

La infraestructura AWS se define en [infra/terraform](infra/terraform). Terraform administra red, grupos de seguridad, repositorios ECR, ECS, EC2 para MySQL y logs en CloudWatch.

## CI/CD

Los workflows se encuentran en [.github/workflows](.github/workflows):

- `container-images.yml`: construye imagenes Docker y publica en ECR desde `deploy`.
- `ecs-deploy.yml`: actualiza el servicio ECS despues de publicar imagenes.

## Despliegue

El flujo manual y automatizado de despliegue hacia AWS ECS esta documentado en [deploy/aws-ecs.md](deploy/aws-ecs.md).
