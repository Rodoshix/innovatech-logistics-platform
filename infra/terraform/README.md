# Terraform

Esta carpeta contiene la infraestructura AWS definida como codigo.

## Recursos

- Red base: VPC, subnets publicas, subnets privadas, Internet Gateway, NAT Gateway y tablas de rutas separadas.
- Security Groups para ALB publico, tareas ECS privadas y acceso a base de datos.
- Application Load Balancer publico para exponer la aplicacion.
- Amazon ECR para las imagenes de `frontend-despachos`, `api-despachos` y `api-ventas`.
- Amazon ECS Fargate para ejecutar la aplicacion contenerizada en subnets privadas.
- Amazon EKS con managed node group para orquestacion Kubernetes.
- Amazon EC2 privado con Docker para ejecutar MySQL con volumen persistente.
- CloudWatch Log Groups para logs de servicios.
- Referencia a `LabRole` para ejecucion de recursos administrados.
- Outputs para IDs, nombres, URLs de repositorios, servicio ECS, cluster EKS, ALB publico e IP privada de base de datos.

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

La configuracion completa de credenciales y variables esta documentada en `docs/aws-setup.md`.

## Comandos

Desde esta carpeta:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

La base EKS reutiliza `LabRole`; no crea roles IAM nuevos. El laboratorio debe tener permisos para crear EKS, managed node groups y recursos de red asociados.

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
- El flujo manual de build, push y despliegue ECS esta documentado en `deploy/aws-ecs.md`.
- La arquitectura objetivo EKS esta documentada en `docs/eks-architecture.md`.
- La operacion del cluster EKS esta documentada en `docs/eks-operations.md`.
