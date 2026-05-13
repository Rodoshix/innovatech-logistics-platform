# Terraform

Esta carpeta contiene la infraestructura AWS definida como codigo.

## Recursos

- Red base: VPC, subred publica, Internet Gateway y tabla de rutas publica.
- Security Groups para entrada publica, trafico interno y acceso a base de datos.
- Amazon ECR para las imagenes de `frontend-despachos`, `api-despachos` y `api-ventas`.
- Amazon ECS Fargate para ejecutar la aplicacion contenerizada.
- Amazon EC2 con Docker para ejecutar MySQL con volumen persistente.
- CloudWatch Log Groups para logs de servicios.
- Referencia a `LabRole` para ejecucion de recursos administrados.
- Outputs para IDs, nombres, URLs de repositorios e IP privada de base de datos.

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
- `.terraform.lock.hcl` se versiona para fijar la version del provider utilizada por el proyecto.
