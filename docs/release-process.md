# Proceso de release

Esta guia define como promover cambios desde integracion hasta una version estable.

## Flujo

```text
feature/* -> develop -> deploy -> main
```

## Preparar integracion

Antes de promover cambios:

- Todos los pull requests hacia `develop` deben estar mergeados.
- Los workflows de build deben pasar correctamente.
- La documentacion operativa debe estar actualizada.
- Terraform debe estar validado con `terraform validate`.

## Promover `develop` hacia `deploy`

Actualizar la rama `deploy` desde `develop`:

```bash
git checkout deploy
git pull origin deploy
git merge origin/develop
git push origin deploy
```

El push a `deploy` activa:

1. Build de imagenes Docker.
2. Publicacion de imagenes en Amazon ECR.
3. Redeploy del servicio ECS.
4. Espera de estabilidad del servicio.

## Validar despliegue

Despues del despliegue, ejecutar el checklist documentado en `docs/deployment-validation.md`:

- Verificar estado del servicio ECS.
- Obtener URL publica del Application Load Balancer.
- Probar `/health`.
- Probar `/api/v1/despachos`.
- Probar `/api/v1/ventas`.
- Revisar logs CloudWatch si hay errores.

## Promover `develop` hacia `main`

Cuando el despliegue fue validado, promover la version estable:

```bash
git checkout main
git pull origin main
git merge origin/develop
git push origin main
```

## Tag de version

Opcionalmente, crear un tag para identificar la version estable:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Criterios de cierre

- Frontend accesible desde la URL publica.
- APIs responden correctamente a traves del frontend/Nginx.
- ECS service en estado estable.
- Logs disponibles en CloudWatch.
- MySQL operativo y accesible desde las APIs.
- Infraestructura reproducible desde Terraform.
- Workflows CI/CD documentados y configurados.
