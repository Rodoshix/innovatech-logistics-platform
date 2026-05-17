# GitHub Actions

Esta carpeta contiene los workflows CI/CD del proyecto.

## Workflows

- `container-images.yml`: construye las imagenes Docker de `frontend-despachos`, `api-despachos` y `api-ventas`.
- `ecs-deploy.yml`: actualiza el servicio ECS cuando las imagenes ya fueron publicadas.

## Comportamiento

- En pull requests hacia `develop`, el workflow construye las imagenes para validar Dockerfiles y dependencias.
- En push hacia `develop`, el workflow construye las imagenes sin publicarlas.
- En push hacia `deploy`, el workflow construye y publica las imagenes en Amazon ECR.
- Cuando la publicacion de imagenes termina correctamente en `deploy`, el workflow de ECS fuerza un nuevo despliegue del servicio.
- Ambos workflows pueden ejecutarse manualmente desde GitHub Actions con `workflow_dispatch`.

## Variables

Configurar en GitHub Actions como repository variables:

| Variable | Valor esperado |
| --- | --- |
| `AWS_REGION` | Region AWS, por ejemplo `us-east-1`. |
| `PROJECT_NAME` | Nombre base usado por Terraform, por ejemplo `innovatech-logistics`. |
| `ENVIRONMENT` | Ambiente usado por Terraform, por ejemplo `dev`. |
| `ECS_CLUSTER_NAME` | Nombre del cluster ECS. Si no se configura, se calcula desde `PROJECT_NAME` y `ENVIRONMENT`. |
| `ECS_SERVICE_NAME` | Nombre del servicio ECS. Si no se configura, se calcula desde `PROJECT_NAME` y `ENVIRONMENT`. |
| `ALB_NAME` | Nombre del Application Load Balancer. Si no se configura, se calcula desde `PROJECT_NAME` y `ENVIRONMENT`. |

Si no se configuran, el workflow usa los valores por defecto del modulo Terraform.

## Secrets

Configurar en GitHub Actions como repository secrets:

| Secret | Uso |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Access key usada por AWS CLI y ECR. |
| `AWS_SECRET_ACCESS_KEY` | Secret key asociada. |
| `AWS_SESSION_TOKEN` | Token temporal si la cuenta lo requiere. |

Los secrets AWS son necesarios cuando el workflow publica imagenes en ECR o actualiza ECS. Los repositorios ECR, el cluster y el servicio ECS deben existir antes de ejecutar el despliegue. Se crean con Terraform.

La guia completa de configuracion esta disponible en `docs/aws-setup.md`.
