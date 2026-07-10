# Decisiones iniciales

## Monorepo

El proyecto utiliza un monorepo para gestionar frontend, servicios backend, despliegue, infraestructura y documentacion desde una unica fuente de verdad. Esta estructura facilita la trazabilidad de cambios y mantiene una vision completa de la plataforma.

## Separacion de aplicaciones

Las aplicaciones se ubican bajo `apps/` para diferenciar claramente los componentes funcionales:

- `frontend-despachos`: interfaz de usuario React/Vite.
- `api-despachos`: API Spring Boot responsable de despachos.
- `api-ventas`: API Spring Boot responsable de ventas.

## Separacion DevOps

Los elementos de operacion se separan de las aplicaciones:

- `infra/terraform`: recursos AWS definidos como infraestructura como codigo.
- `deploy`: archivos de ejecucion, Docker Compose y configuracion de despliegue.
- `.github/workflows`: automatizacion CI/CD.
- `docs`: documentacion tecnica del proyecto.

## Registro de imagenes

Las imagenes se publican en Amazon ECR para mantener el flujo de contenedores dentro del proveedor cloud usado por la plataforma.

## Orquestacion

Los servicios de aplicacion se ejecutan en Amazon EKS sobre Kubernetes dentro de subnets privadas. La entrada publica se realiza mediante un Application Load Balancer gestionado por AWS Load Balancer Controller a partir de un Ingress Kubernetes. La base de datos MySQL se ejecuta en EC2 privada con Docker y volumen persistente.

## Red AWS

La red separa la capa publica y privada:

- Subnets publicas para ALB y NAT Gateway.
- Subnets privadas para nodos EKS, pods de aplicacion y MySQL.
- Internet Gateway para entrada publica.
- NAT Gateway para salida controlada desde subnets privadas.
- Security Groups para restringir trafico entre ALB, EKS y MySQL.
