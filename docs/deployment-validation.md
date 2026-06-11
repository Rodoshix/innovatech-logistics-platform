# Validacion de despliegue

Esta guia contiene comandos de verificacion para confirmar que la plataforma quedo operativa despues de desplegar en Amazon EKS.

## Variables de trabajo

Definir estos valores antes de ejecutar comandos:

```bash
export AWS_REGION="us-east-1"
export EKS_CLUSTER_NAME="innovatech-logistics-dev-eks"
export NAMESPACE="innovatech"
```

En PowerShell:

```powershell
$env:AWS_REGION="us-east-1"
$env:EKS_CLUSTER_NAME="innovatech-logistics-dev-eks"
$env:NAMESPACE="innovatech"
```

## Acceso al cluster

Configurar `kubectl` contra EKS:

```bash
aws eks update-kubeconfig \
  --region "$AWS_REGION" \
  --name "$EKS_CLUSTER_NAME"
```

Validar nodos:

```bash
kubectl get nodes -o wide
```

El resultado esperado es al menos un nodo en estado `Ready`.

## Estado de workloads

Revisar recursos principales:

```bash
kubectl get pods,deployments,svc,ingress,hpa -n "$NAMESPACE" -o wide
```

Validar rollouts:

```bash
kubectl rollout status deployment/frontend-despachos -n "$NAMESPACE"
kubectl rollout status deployment/api-despachos -n "$NAMESPACE"
kubectl rollout status deployment/api-ventas -n "$NAMESPACE"
```

Resultado esperado:

- Deployments disponibles.
- Pods en `Running`.
- Services internos creados.
- HPA creado para frontend y APIs.
- Ingress creado para entrada publica.

## Estado de add-ons

Validar AWS Load Balancer Controller:

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

Validar Metrics Server:

```bash
kubectl get deployment -n kube-system metrics-server
kubectl get apiservice v1beta1.metrics.k8s.io
```

## Obtener URL publica

Obtener hostname del Ingress:

```bash
APPLICATION_HOST=$(kubectl get ingress innovatech-ingress \
  -n "$NAMESPACE" \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$APPLICATION_HOST"
```

Si el hostname aparece vacio, revisar que AWS Load Balancer Controller este instalado y que el Ingress no tenga eventos de error.

## Probar endpoints

```bash
curl "http://$APPLICATION_HOST/health"
curl "http://$APPLICATION_HOST/api/v1/despachos"
curl "http://$APPLICATION_HOST/api/v1/ventas"
```

Resultado esperado:

- `/health` responde `ok`.
- `/api/v1/despachos` responde JSON.
- `/api/v1/ventas` responde JSON.

## Logs de aplicacion

Frontend:

```bash
kubectl logs -n "$NAMESPACE" deployment/frontend-despachos
```

API despachos:

```bash
kubectl logs -n "$NAMESPACE" deployment/api-despachos
```

API ventas:

```bash
kubectl logs -n "$NAMESPACE" deployment/api-ventas
```

## Eventos del namespace

```bash
kubectl get events -n "$NAMESPACE" --sort-by=.lastTimestamp
```

Este comando es util para diagnosticar errores de pull de imagen, probes fallidas, Ingress sin balanceador o problemas de scheduling.

## Diagnostico rapido

Si los pods no inician:

```bash
kubectl describe pod -n "$NAMESPACE" <pod-name>
kubectl logs -n "$NAMESPACE" <pod-name>
```

Si una imagen no se encuentra:

- Confirmar que los repositorios ECR existen.
- Confirmar que el workflow `EKS Delivery` publico los tags `latest`.
- Confirmar que el nombre de repositorio coincide con `project_name`, `environment` y nombre del servicio.
- Confirmar que los nodos EKS tienen permisos para descargar desde ECR.

Si las APIs no conectan a MySQL:

- Confirmar que la instancia EC2 de base de datos esta en ejecucion.
- Confirmar que `DB_ENDPOINT` en el `ConfigMap` apunta a la IP privada correcta.
- Confirmar que el Security Group de base de datos permite trafico desde el Security Group del cluster EKS.
- Revisar logs de `api-despachos` y `api-ventas`.

Si el Ingress no entrega URL publica:

- Confirmar que AWS Load Balancer Controller esta instalado.
- Revisar eventos del Ingress.
- Confirmar que las subnets publicas tienen tags de Kubernetes para balanceadores externos.
- Confirmar que el Ingress usa `ingressClassName: alb`.

Si el HPA no muestra metricas:

- Confirmar que Metrics Server esta instalado.
- Confirmar que los deployments tienen `resources.requests.cpu` definido.
- Revisar `kubectl describe hpa -n "$NAMESPACE"`.
