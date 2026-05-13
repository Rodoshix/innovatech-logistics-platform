# AWS ECS Deployment

Esta guia describe el despliegue manual de la plataforma en AWS usando ECR, ECS Fargate, EC2, CloudWatch y Terraform.

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

Terraform crea la red, grupos de seguridad, repositorios ECR, cluster ECS, servicio ECS, logs en CloudWatch y la instancia EC2 que ejecuta MySQL.

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

Este flujo manual queda automatizado por el workflow `.github/workflows/container-images.yml` cuando se hace push a `develop`, push a `deploy` o ejecucion manual desde GitHub Actions.

## Actualizar ECS

Forzar un nuevo despliegue del servicio:

```bash
aws ecs update-service \
  --cluster <ecs-cluster-name> \
  --service <ecs-service-name> \
  --force-new-deployment
```

## Obtener URL publica

El servicio ECS usa una task Fargate con IP publica. Para obtenerla:

```bash
TASK_ARN=$(aws ecs list-tasks \
  --cluster <ecs-cluster-name> \
  --service-name <ecs-service-name> \
  --query "taskArns[0]" \
  --output text)

ENI_ID=$(aws ecs describe-tasks \
  --cluster <ecs-cluster-name> \
  --tasks "$TASK_ARN" \
  --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" \
  --output text)

PUBLIC_IP=$(aws ec2 describe-network-interfaces \
  --network-interface-ids "$ENI_ID" \
  --query "NetworkInterfaces[0].Association.PublicIp" \
  --output text)

echo "http://$PUBLIC_IP"
```

## Verificacion

Abrir la URL publica en el navegador y validar:

```bash
curl http://$PUBLIC_IP/health
curl http://$PUBLIC_IP/api/v1/despachos
curl http://$PUBLIC_IP/api/v1/ventas
```

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
