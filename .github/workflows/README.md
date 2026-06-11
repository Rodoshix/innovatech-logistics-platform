# GitHub Actions

Esta carpeta contiene los workflows CI/CD del proyecto.

## Workflows

- `container-images.yml`: ejecuta el flujo `EKS Delivery`. Construye las imagenes Docker, publica en Amazon ECR cuando corresponde y despliega los manifiestos Kubernetes en EKS.

## Comportamiento

- En pull requests hacia `develop`, el workflow construye las imagenes para validar Dockerfiles y dependencias.
- En push hacia `develop`, el workflow construye las imagenes sin publicarlas.
- En push hacia `deploy`, el workflow construye, publica imagenes en Amazon ECR y despliega en EKS.
- En push hacia `main`, el workflow ejecuta el mismo flujo de release para la version estable.
- El workflow puede ejecutarse manualmente desde GitHub Actions con `workflow_dispatch`.

## Pasos visibles del flujo

El workflow muestra pasos separados para facilitar revision operacional:

1. Checkout.
2. Preparacion de Docker Buildx.
3. Configuracion de credenciales AWS.
4. Login en Amazon ECR.
5. Build y push de imagenes.
6. Resolucion de cluster, registry y base de datos.
7. Configuracion de `kubectl`.
8. Instalacion o actualizacion de add-ons EKS.
9. Preparacion de manifiestos Kubernetes.
10. Aplicacion de namespace y secreto de base de datos.
11. Aplicacion de manifiestos.
12. Espera de rollouts.
13. Publicacion del estado y endpoint.

## Variables

Configurar en GitHub Actions como repository variables:

| Variable | Valor esperado |
| --- | --- |
| `AWS_REGION` | Region AWS, por ejemplo `us-east-1`. |
| `PROJECT_NAME` | Nombre base usado por Terraform, por ejemplo `innovatech-logistics`. |
| `ENVIRONMENT` | Ambiente usado por Terraform, por ejemplo `dev`. |
| `EKS_CLUSTER_NAME` | Nombre del cluster EKS. Si no se configura, se calcula desde `PROJECT_NAME` y `ENVIRONMENT`. |
| `DB_ENDPOINT` | IP privada o DNS de la base de datos. Si no se configura, el workflow intenta resolver la instancia por tags de Terraform. |

Si no se configuran, el workflow usa los valores por defecto del modulo Terraform.

## Secrets

Configurar en GitHub Actions como repository secrets:

| Secret | Uso |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Access key usada por AWS CLI y ECR. |
| `AWS_SECRET_ACCESS_KEY` | Secret key asociada. |
| `AWS_SESSION_TOKEN` | Token temporal si la cuenta lo requiere. |
| `DB_USERNAME` | Usuario de aplicacion para MySQL. |
| `DB_PASSWORD` | Password de aplicacion para MySQL. |

Los secrets AWS son necesarios cuando el workflow publica imagenes en ECR o despliega en EKS. Los repositorios ECR, el cluster EKS, los nodos y la base de datos deben existir antes de ejecutar el despliegue. Se crean con Terraform.

El workflow tambien requiere que el runner tenga acceso a `kubectl` y `helm`. Los runners `ubuntu-latest` de GitHub Actions incluyen estas herramientas o permiten usarlas directamente durante la ejecucion.

La guia completa de configuracion esta disponible en `docs/aws-setup.md`.
