# Decisiones iniciales

## Monorepo

El proyecto utiliza un monorepo para gestionar frontend, servicios backend, despliegue, infraestructura y documentación desde una única fuente de verdad. Esta estructura simplifica la trazabilidad y mantiene una visión completa de la plataforma.

## Separación de aplicaciones

Las aplicaciones se ubican bajo `apps/` para diferenciar claramente los componentes funcionales:

- `frontend-despachos`: interfaz de usuario React/Vite.
- `api-despachos`: API Spring Boot responsable de despachos.
- `api-ventas`: API Spring Boot responsable de ventas.

## Separación DevOps

Los elementos de operación se separan de las aplicaciones:

- `infra/terraform`: recursos AWS definidos como infraestructura como código.
- `deploy`: archivos de ejecución, Docker Compose y configuración de despliegue.
- `.github/workflows`: automatización CI/CD.
- `docs`: documentación técnica del proyecto.
