# Innovatech Logistics Platform

Plataforma logistica para Innovatech Chile orientada a la gestion de ventas y despachos. El proyecto se organiza como monorepo para centralizar frontend, servicios backend, infraestructura, despliegue y automatizacion CI/CD.

## Arquitectura

La solucion se compone de una aplicacion frontend, dos servicios backend y una base de datos MySQL. En ambiente local se ejecuta con Docker Compose. En AWS se trabaja con imagenes publicadas en Amazon ECR, red administrada con Terraform, entrada HTTP publica mediante balanceador de carga y workloads de aplicacion preparados para Amazon EKS sobre Kubernetes.

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
- Amazon EKS y Kubernetes para orquestacion de aplicaciones.
- Amazon EC2 para runtime MySQL.
- Application Load Balancer para entrada HTTP publica.
- VPC, subnets publicas/privadas, NAT Gateway, Security Groups y CloudWatch para red, seguridad y observabilidad.

## Estructura

```text
innovatech-logistics-platform/
  apps/
    frontend-despachos/
    api-despachos/
    api-ventas/
  deploy/
    docker-compose.yml
  infra/
    terraform/
  k8s/
    namespace.yaml
    *-deployment.yaml
    *-service.yaml
    ingress.yaml
    hpa.yaml
  .github/
    workflows/
  docs/
```

## Componentes

| Componente | Ruta | Tecnologia | Puerto |
| --- | --- | --- | --- |
| Frontend despachos | `apps/frontend-despachos` | React/Vite + Nginx | `8082` interno / `80` publico |
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

La infraestructura AWS se define en [infra/terraform](infra/terraform). Terraform administra red publica/privada, NAT Gateway, grupos de seguridad, Application Load Balancer, repositorios ECR, EKS, EC2 para MySQL y recursos base de observabilidad.

La arquitectura objetivo de Kubernetes esta documentada en [docs/eks-architecture.md](docs/eks-architecture.md). La operacion del cluster EKS esta documentada en [docs/eks-operations.md](docs/eks-operations.md).

## CI/CD

Los workflows se encuentran en [.github/workflows](.github/workflows):

- `container-images.yml`: ejecuta `EKS Delivery` con validaciones de frontend y backend, construccion de imagenes Docker, publicacion en ECR, configuracion de `kubectl`, aplicacion de manifiestos Kubernetes, espera de rollouts en EKS y validacion HTTP de endpoints.

## Despliegue

El flujo de despliegue hacia Amazon EKS esta documentado en [docs/eks-operations.md](docs/eks-operations.md) y los manifiestos Kubernetes se encuentran en [k8s](k8s).

## Configuracion

La preparacion de AWS CLI, Terraform variables y GitHub Secrets/Variables esta documentada en [docs/aws-setup.md](docs/aws-setup.md).

## Validacion

El checklist de validacion del despliegue, revision de Kubernetes y pruebas de endpoints esta documentado en [docs/deployment-validation.md](docs/deployment-validation.md).

## Release

El proceso para promover cambios desde `develop` hacia `deploy` y `main` esta documentado en [docs/release-process.md](docs/release-process.md).
