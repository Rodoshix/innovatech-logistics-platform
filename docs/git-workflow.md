# Flujo Git del proyecto

## Ramas principales

- `main`: contiene la versión estable del proyecto.
- `develop`: integra las ramas de trabajo aprobadas antes de promover cambios hacia `main`.
- `deploy`: activa el pipeline de despliegue continuo hacia AWS.

## Flujo de ramas

```text
feature/* -> develop -> main
```

Las ramas `feature/*` se crean desde `develop` y vuelven a `develop` mediante pull request. La rama `deploy` se reserva para publicar versiones desplegables.

## Convención de commits

- `chore`: estructura, configuración o tareas de mantenimiento.
- `feat`: nueva funcionalidad o capacidad técnica.
- `fix`: corrección de errores.
- `docs`: documentación.
- `ci`: pipelines y automatización.
- `infra`: infraestructura como código.

Ejemplos:

```text
chore: bootstrap monorepo structure
feat: add docker compose stack
infra: define aws network baseline
ci: add deploy workflow for ec2
docs: document deployment procedure
```
