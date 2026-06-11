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
| `app_image_tag` | Tag base de imagen para los contenedores. |
| `eks_version` | Version de Kubernetes para Amazon EKS. |
| `eks_node_instance_types` | Tipos de instancia permitidos para el node group. |
| `eks_node_desired_size` | Cantidad deseada de nodos del node group. |

El archivo `terraform.tfvars` contiene valores sensibles y no debe versionarse.

## GitHub repository variables

Configurar en `Settings > Secrets and variables > Actions > Variables`:

| Variable | Valor recomendado |
| --- | --- |
| `AWS_REGION` | `us-east-1` |
| `PROJECT_NAME` | `innovatech-logistics` |
| `ENVIRONMENT` | `dev` |
| `EKS_CLUSTER_NAME` | `innovatech-logistics-dev-eks` |
| `DB_ENDPOINT` | IP privada o DNS de MySQL. Opcional si el workflow puede resolver la instancia por tags. |

`EKS_CLUSTER_NAME` es opcional si se mantiene la convencion de nombres generada por Terraform.

## GitHub repository secrets

Configurar en `Settings > Secrets and variables > Actions > Secrets`:

| Secret | Uso |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Access key para autenticar los workflows en AWS. |
| `AWS_SECRET_ACCESS_KEY` | Secret key asociada. |
| `AWS_SESSION_TOKEN` | Token temporal cuando la cuenta lo requiere. |
| `DB_USERNAME` | Usuario de aplicacion MySQL. |
| `DB_PASSWORD` | Password del usuario de aplicacion MySQL. |

Los secrets AWS se usan para publicar imagenes en ECR y desplegar en EKS. Los pull requests hacia `develop` construyen imagenes sin publicar.

## Orden de preparacion

1. Configurar AWS CLI local.
2. Crear `infra/terraform/terraform.tfvars`.
3. Ejecutar `terraform init`, `terraform plan` y `terraform apply`.
4. Confirmar que existen ECR, EKS, nodos, EC2 MySQL y CloudWatch.
5. Configurar variables y secrets en GitHub.
6. Actualizar la rama `deploy` o `main` desde `develop` para activar build, push y despliegue.
