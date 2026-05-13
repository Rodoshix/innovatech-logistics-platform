# Validacion de despliegue

Esta guia contiene comandos de verificacion para confirmar que la plataforma quedo operativa despues de desplegar en AWS.

## Variables de trabajo

Definir estos valores antes de ejecutar comandos:

```bash
export AWS_REGION="us-east-1"
export ECS_CLUSTER_NAME="innovatech-logistics-dev-cluster"
export ECS_SERVICE_NAME="innovatech-logistics-dev-app-service"
```

En PowerShell:

```powershell
$env:AWS_REGION="us-east-1"
$env:ECS_CLUSTER_NAME="innovatech-logistics-dev-cluster"
$env:ECS_SERVICE_NAME="innovatech-logistics-dev-app-service"
```

## Estado del servicio ECS

```bash
aws ecs describe-services \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --services "$ECS_SERVICE_NAME" \
  --query "services[0].{status:status,running:runningCount,desired:desiredCount,pending:pendingCount,deployments:deployments[*].rolloutState}"
```

El resultado esperado es:

- `status`: `ACTIVE`
- `running`: `1`
- `desired`: `1`
- `pending`: `0`

## Obtener task activa

```bash
TASK_ARN=$(aws ecs list-tasks \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --service-name "$ECS_SERVICE_NAME" \
  --query "taskArns[0]" \
  --output text)

echo "$TASK_ARN"
```

## Revisar detalle de la task

```bash
aws ecs describe-tasks \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --tasks "$TASK_ARN" \
  --query "tasks[0].{lastStatus:lastStatus,desiredStatus:desiredStatus,healthStatus:healthStatus,containers:containers[*].{name:name,lastStatus:lastStatus,exitCode:exitCode,reason:reason}}"
```

La task debe estar en `RUNNING` y los contenedores deben aparecer activos.

## Obtener URL publica

```bash
ENI_ID=$(aws ecs describe-tasks \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --tasks "$TASK_ARN" \
  --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" \
  --output text)

PUBLIC_IP=$(aws ec2 describe-network-interfaces \
  --region "$AWS_REGION" \
  --network-interface-ids "$ENI_ID" \
  --query "NetworkInterfaces[0].Association.PublicIp" \
  --output text)

echo "http://$PUBLIC_IP"
```

## Probar endpoints

```bash
curl "http://$PUBLIC_IP/health"
curl "http://$PUBLIC_IP/api/v1/despachos"
curl "http://$PUBLIC_IP/api/v1/ventas"
```

Resultado esperado:

- `/health` responde `ok`.
- `/api/v1/despachos` responde JSON.
- `/api/v1/ventas` responde JSON.

## Logs CloudWatch

Listar log groups creados por Terraform:

```bash
aws logs describe-log-groups \
  --region "$AWS_REGION" \
  --log-group-name-prefix "/ecs/innovatech-logistics-dev"
```

Seguir logs por servicio:

```bash
aws logs tail "/ecs/innovatech-logistics-dev/frontend-despachos" --region "$AWS_REGION" --follow
aws logs tail "/ecs/innovatech-logistics-dev/api-despachos" --region "$AWS_REGION" --follow
aws logs tail "/ecs/innovatech-logistics-dev/api-ventas" --region "$AWS_REGION" --follow
```

## Diagnostico rapido

Si la task no queda en `RUNNING`:

```bash
aws ecs describe-services \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --services "$ECS_SERVICE_NAME" \
  --query "services[0].events[0:5]"
```

Si una imagen no se encuentra:

- Confirmar que los repositorios ECR existen.
- Confirmar que el workflow `Container Images` publico los tags `latest`.
- Confirmar que el nombre de repositorio coincide con `project_name`, `environment` y nombre del servicio.

Si las APIs no conectan a MySQL:

- Confirmar que la instancia EC2 de base de datos esta en ejecucion.
- Confirmar que `database_private_ip` de Terraform coincide con `DB_ENDPOINT` en la task definition.
- Confirmar que el Security Group de base de datos permite trafico desde el Security Group de ECS.
- Revisar logs de `api-despachos` y `api-ventas` en CloudWatch.
