# Configuracion AWS y GitHub

Esta guia concentra los valores necesarios para ejecutar Terraform y los workflows CI/CD del proyecto.

## AWS CLI

Configurar credenciales locales antes de ejecutar Terraform o comandos AWS:

```bash
aws configure
```

Validar identidad activa:

```bash
aws sts get-caller-identity
```

Si se trabaja con credenciales temporales, exportar tambien el token de sesion:

```bash
export AWS_SESSION_TOKEN="<session-token>"
```

En PowerShell:

```powershell
$env:AWS_SESSION_TOKEN="<session-token>"
```

## Terraform variables

Crear el archivo local:

```powershell
Copy-Item infra\terraform\terraform.tfvars.example infra\terraform\terraform.tfvars
```

Actualizar como minimo estos valores:

| Variable | Uso |
| --- | --- |
| `aws_region` | Region AWS donde se crean los recursos. |
| `project_name` | Prefijo principal de recursos. |
| `environment` | Ambiente de despliegue. |
| `db_password` | Password del usuario de aplicacion MySQL. |
| `db_root_password` | Password root de MySQL. |
| `app_image_tag` | Tag de imagen que ECS usara para los contenedores. |

El archivo `terraform.tfvars` contiene valores sensibles y no debe versionarse.

## GitHub repository variables

Configurar en `Settings > Secrets and variables > Actions > Variables`:

| Variable | Valor recomendado |
| --- | --- |
| `AWS_REGION` | `us-east-1` |
| `PROJECT_NAME` | `innovatech-logistics` |
| `ENVIRONMENT` | `dev` |
| `ECS_CLUSTER_NAME` | `innovatech-logistics-dev-cluster` |
| `ECS_SERVICE_NAME` | `innovatech-logistics-dev-app-service` |

`ECS_CLUSTER_NAME` y `ECS_SERVICE_NAME` son opcionales si se mantiene la convencion de nombres generada por Terraform.

## GitHub repository secrets

Configurar en `Settings > Secrets and variables > Actions > Secrets`:

| Secret | Uso |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Access key para autenticar los workflows en AWS. |
| `AWS_SECRET_ACCESS_KEY` | Secret key asociada. |
| `AWS_SESSION_TOKEN` | Token temporal cuando la cuenta lo requiere. |

Los secrets AWS se usan solo para publicar imagenes en ECR y actualizar ECS. Los pull requests hacia `develop` construyen imagenes sin publicar.

## Orden de preparacion

1. Configurar AWS CLI local.
2. Crear `infra/terraform/terraform.tfvars`.
3. Ejecutar `terraform init`, `terraform plan` y `terraform apply`.
4. Confirmar que existen ECR, ECS, EC2 y CloudWatch.
5. Configurar variables y secrets en GitHub.
6. Actualizar la rama `deploy` desde `develop` para activar build, push y despliegue.
