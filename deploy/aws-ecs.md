# AWS ECS Deployment

Esta guia describe el despliegue manual de la plataforma en AWS usando ECR, ECS Fargate, EC2, Application Load Balancer, CloudWatch y Terraform.

## Prerrequisitos

- AWS CLI configurado con acceso a la cuenta de despliegue.
- Docker disponible localmente.
- Terraform inicializado en `infra/terraform`.
- Imagenes de aplicacion construidas desde el monorepo.
- Archivo local `infra/terraform/terraform.tfvars` creado desde `terraform.tfvars.example`.

## Crear infraestructura

Desde `infra/terraform`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Terraform crea la red publica/privada, NAT Gateway, grupos de seguridad, Application Load Balancer, repositorios ECR, cluster ECS, servicio ECS, logs en CloudWatch y la instancia EC2 privada que ejecuta MySQL.

## Obtener datos de ECR

Desde `infra/terraform`:

```bash
terraform output ecr_repository_urls
terraform output ecs_cluster_name
terraform output ecs_service_name
```

Guardar las URLs de los tres repositorios:

- `frontend_despachos`
- `api_despachos`
- `api_ventas`

## Login en ECR

Reemplazar `<aws-region>` y `<account-id>` con los valores de la cuenta:

```bash
aws ecr get-login-password --region <aws-region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<aws-region>.amazonaws.com
```

## Build y push de imagenes

Desde la raiz del repositorio:

```bash
docker build -t frontend-despachos:latest apps/frontend-despachos
docker build -t api-despachos:latest apps/api-despachos
docker build -t api-ventas:latest apps/api-ventas
```

Etiquetar cada imagen con la URL entregada por Terraform:

```bash
docker tag frontend-despachos:latest <frontend-ecr-url>:latest
docker tag api-despachos:latest <api-despachos-ecr-url>:latest
docker tag api-ventas:latest <api-ventas-ecr-url>:latest
```

Subir las imagenes:

```bash
docker push <frontend-ecr-url>:latest
docker push <api-despachos-ecr-url>:latest
docker push <api-ventas-ecr-url>:latest
```

Este flujo manual queda automatizado por el workflow `.github/workflows/container-images.yml` cuando se hace push a `deploy` o ejecucion manual desde GitHub Actions. En `develop`, el workflow solo valida la construccion de imagenes.

## Actualizar ECS

Forzar un nuevo despliegue del servicio:

```bash
aws ecs update-service \
  --cluster <ecs-cluster-name> \
  --service <ecs-service-name> \
  --force-new-deployment
```

Este paso queda automatizado por el workflow `.github/workflows/ecs-deploy.yml` cuando el workflow de imagenes termina correctamente en la rama `deploy`.

## Obtener URL publica

La aplicacion se expone mediante el Application Load Balancer. Para obtener la URL:

```bash
terraform output application_url
```

## Verificacion

Abrir la URL publica en el navegador y validar:

```bash
curl "$(terraform output -raw application_url)/health"
curl "$(terraform output -raw application_url)/api/v1/despachos"
curl "$(terraform output -raw application_url)/api/v1/ventas"
```

El checklist completo de validacion y diagnostico esta disponible en `docs/deployment-validation.md`.

## Logs

Los logs quedan separados por servicio en CloudWatch:

```bash
terraform output cloudwatch_log_group_names
```

## Limpieza

Para eliminar recursos creados por Terraform:

```bash
terraform destroy
```
