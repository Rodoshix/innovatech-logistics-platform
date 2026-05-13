# Flujo Git del proyecto

## Ramas principales

- `main`: contiene la version estable del proyecto.
- `develop`: integra las ramas de trabajo aprobadas antes de promover cambios.
- `deploy`: activa publicacion de imagenes y despliegue continuo hacia AWS.

## Flujo de ramas

```text
feature/* -> develop -> deploy -> main
```

Las ramas `feature/*` se crean desde `develop` y vuelven a `develop` mediante pull request. La rama `deploy` se actualiza desde `develop` cuando se quiere publicar una version desplegable. `main` se actualiza cuando la version ya fue validada.

El proceso operativo para promover cambios esta documentado en `docs/release-process.md`.

## Convencion de commits

- `chore`: estructura, configuracion o tareas de mantenimiento.
- `feat`: nueva funcionalidad o capacidad tecnica.
- `fix`: correccion de errores.
- `docs`: documentacion.
- `ci`: pipelines y automatizacion.
- `infra`: infraestructura como codigo.

Ejemplos:

```text
chore: bootstrap monorepo structure
feat: add docker compose stack
infra: define aws network baseline
ci: publish images to ecr
docs: document deployment validation
```
