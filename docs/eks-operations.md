# Operacion EKS

Esta guia resume los comandos y verificaciones operativas para trabajar con el cluster EKS de Innovatech Logistics Platform.

## Requisitos locales

Antes de operar el cluster, el equipo local debe contar con:

- AWS CLI configurado.
- Terraform instalado.
- `kubectl` instalado.
- Credenciales activas del laboratorio AWS.
- Archivo local `infra/terraform/terraform.tfvars` creado desde el ejemplo.

Validar identidad AWS:

```bash
aws sts get-caller-identity
```

## Provisionamiento de infraestructura

Desde `infra/terraform`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

El `apply` debe ejecutarse manualmente y solo cuando el plan haya sido revisado:

```bash
terraform apply
```

## Configurar acceso kubectl

Una vez creado el cluster EKS, obtener el nombre desde Terraform:

```bash
terraform output -raw eks_cluster_name
```

Configurar kubeconfig:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name "$(terraform output -raw eks_cluster_name)"
```

Validar conexion:

```bash
kubectl get nodes
kubectl get namespaces
```

## Validaciones base del cluster

Revisar nodos:

```bash
kubectl get nodes -o wide
```

Revisar componentes del cluster:

```bash
kubectl get pods -A
```

Revisar eventos recientes:

```bash
kubectl get events -A --sort-by=.lastTimestamp
```

## Namespace de aplicacion

La aplicacion usara el namespace:

```text
innovatech
```

Comando esperado:

```bash
kubectl get all -n innovatech
```

## Manifiestos Kubernetes

Los manifiestos de aplicacion se mantienen en `k8s/` e incluyen:

- Namespace.
- ConfigMap.
- Secret de ejemplo.
- Deployments.
- Services internos.
- Ingress.
- HPA.
- Kustomization.

La guia especifica de aplicacion se encuentra en `k8s/README.md`.

## Add-ons del cluster

Antes de aplicar los manifiestos de aplicacion, el cluster requiere:

- AWS Load Balancer Controller para procesar el `Ingress` y crear el ALB.
- Metrics Server para entregar metricas al HPA.

Instalacion manual:

```bash
bash scripts/eks/install-addons.sh
```

La guia especifica se encuentra en `k8s/addons/README.md`.

Flujo operativo esperado:

```bash
kubectl apply -f k8s/namespace.yaml

kubectl create secret generic innovatech-db-secret \
  --namespace innovatech \
  --from-literal=DB_USERNAME="$DB_USERNAME" \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -k k8s
```

Luego se debe actualizar el `ConfigMap` con la IP privada de la base de datos entregada por Terraform y reiniciar los deployments para tomar la configuracion actualizada.

## Validacion de workloads

Una vez aplicados los manifiestos Kubernetes:

```bash
kubectl get deployments -n innovatech
kubectl get pods -n innovatech
kubectl get svc -n innovatech
kubectl get ingress -n innovatech
```

Validar rollout:

```bash
kubectl rollout status deployment/frontend-despachos -n innovatech
kubectl rollout status deployment/api-despachos -n innovatech
kubectl rollout status deployment/api-ventas -n innovatech
```

## Logs

Frontend:

```bash
kubectl logs -n innovatech deployment/frontend-despachos
```

API despachos:

```bash
kubectl logs -n innovatech deployment/api-despachos
```

API ventas:

```bash
kubectl logs -n innovatech deployment/api-ventas
```

## Autoscaling

El autoscaling se validara mediante HPA:

```bash
kubectl get hpa -n innovatech
kubectl describe hpa -n innovatech
```

Resultado esperado:

- HPA creado para los workloads definidos.
- Metricas disponibles.
- Replicas dentro de los limites configurados.

## Limpieza

Para eliminar recursos creados por Terraform:

```bash
terraform destroy
```

Antes de destruir, confirmar que no se requiere conservar evidencia de:

- URL publica.
- Capturas de workloads.
- Logs.
- Metricas.
- Estado de HPA.
- Ejecuciones de GitHub Actions.

## Restricciones

- No se crean roles IAM nuevos desde Terraform.
- El cluster y el node group reutilizan `LabRole`.
- El usuario ejecuta manualmente `terraform apply` y `terraform destroy`.
- Las credenciales temporales de AWS deben renovarse cuando expire el laboratorio.
