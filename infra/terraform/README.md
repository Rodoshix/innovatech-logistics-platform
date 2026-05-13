# Terraform

Esta carpeta contiene la infraestructura AWS definida como código.

## Recursos

- Red base: VPC, subred pública, Internet Gateway y tabla de rutas pública.
- Security Groups para frontend, backends y base de datos.
- Amazon ECR para las imágenes de `frontend-despachos`, `api-despachos` y `api-ventas`.
- Amazon ECS Cluster para orquestación de contenedores.
- CloudWatch Log Groups para logs de servicios.
- Referencia a `LabRole` para ejecución de recursos administrados.
- Outputs para IDs, nombres y URLs relevantes.

## Variables

Crear un archivo local de variables desde el ejemplo:

```bash
copy infra\terraform\terraform.tfvars.example infra\terraform\terraform.tfvars
```

En PowerShell:

```powershell
Copy-Item infra\terraform\terraform.tfvars.example infra\terraform\terraform.tfvars
```

El archivo `terraform.tfvars` no debe versionarse.

## Comandos

Desde esta carpeta:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Para crear recursos en AWS:

```bash
terraform apply
```

Para eliminar los recursos creados:

```bash
terraform destroy
```

## Notas

- `terraform apply` y `terraform destroy` modifican recursos reales en AWS.
- `.terraform/`, `terraform.tfstate` y `terraform.tfvars` se mantienen fuera del repositorio.
- `.terraform.lock.hcl` se versiona para fijar la versión del provider utilizada por el proyecto.
