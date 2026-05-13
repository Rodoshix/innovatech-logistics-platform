# GitHub Actions

Esta carpeta contiene los workflows CI/CD del proyecto.

## Workflows

- `container-images.yml`: construye las imagenes Docker de `frontend-despachos`, `api-despachos` y `api-ventas`.

## Comportamiento

- En pull requests hacia `develop`, el workflow solo construye las imagenes para validar Dockerfiles y dependencias.
- En push hacia `develop` o `deploy`, el workflow construye y publica las imagenes en Amazon ECR.
- Tambien puede ejecutarse manualmente desde GitHub Actions con `workflow_dispatch`.

## Variables

Configurar en GitHub Actions como repository variables:

| Variable | Valor esperado |
| --- | --- |
| `AWS_REGION` | Region AWS, por ejemplo `us-east-1`. |
| `PROJECT_NAME` | Nombre base usado por Terraform, por ejemplo `innovatech-logistics`. |
| `ENVIRONMENT` | Ambiente usado por Terraform, por ejemplo `dev`. |

Si no se configuran, el workflow usa los valores por defecto del modulo Terraform.

## Secrets

Configurar en GitHub Actions como repository secrets:

| Secret | Uso |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Access key usada por AWS CLI y ECR. |
| `AWS_SECRET_ACCESS_KEY` | Secret key asociada. |
| `AWS_SESSION_TOKEN` | Token temporal si la cuenta lo requiere. |

Los repositorios ECR deben existir antes de publicar imagenes. Se crean con Terraform.
