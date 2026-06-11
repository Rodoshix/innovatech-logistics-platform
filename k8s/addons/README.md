# Add-ons EKS

Esta carpeta documenta los complementos necesarios para operar los manifiestos Kubernetes de la plataforma sobre Amazon EKS.

## Add-ons requeridos

| Add-on | Proposito |
| --- | --- |
| AWS Load Balancer Controller | Procesa recursos `Ingress` y crea el Application Load Balancer en AWS. |
| Metrics Server | Entrega metricas de CPU/memoria usadas por `HorizontalPodAutoscaler`. |

## Restriccion IAM

El entorno usa el rol disponible del laboratorio AWS y no crea roles IAM nuevos desde Terraform. Por ese motivo, el AWS Load Balancer Controller se instala sin IRSA propio y recibe credenciales temporales desde un Secret Kubernetes creado durante la instalacion.

Esto funciona mientras las credenciales temporales del laboratorio esten activas y tengan permisos suficientes para administrar balanceadores, target groups, security groups y recursos relacionados. Cuando el token del laboratorio expire, se debe renovar el Secret ejecutando nuevamente el script o el workflow.

## Instalacion manual

Desde la raiz del repositorio, con `kubectl` apuntando al cluster EKS:

```bash
bash scripts/eks/install-addons.sh
```

Variables opcionales:

```bash
export AWS_REGION="us-east-1"
export EKS_CLUSTER_NAME="innovatech-logistics-dev-eks"
export VPC_ID="$(terraform -chdir=infra/terraform output -raw vpc_id)"
export AWS_ACCESS_KEY_ID="<access-key>"
export AWS_SECRET_ACCESS_KEY="<secret-key>"
export AWS_SESSION_TOKEN="<session-token>"

bash scripts/eks/install-addons.sh
```

## Validacion

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get deployment -n kube-system metrics-server
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl get apiservice v1beta1.metrics.k8s.io
```

## Diagnostico

Revisar logs del controller:

```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

Revisar eventos del Ingress:

```bash
kubectl describe ingress innovatech-ingress -n innovatech
```

Revisar estado de HPA:

```bash
kubectl describe hpa -n innovatech
```

