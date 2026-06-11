# Manifiestos Kubernetes

Esta carpeta contiene la definicion base para ejecutar la plataforma en Amazon EKS.

## Componentes

- `namespace.yaml`: namespace aislado para los recursos de la plataforma.
- `configmap.yaml`: variables no sensibles compartidas por frontend y APIs.
- `secret.example.yaml`: plantilla de credenciales de base de datos. No debe contener secretos reales.
- `*-deployment.yaml`: definicion de pods, imagenes, probes y recursos por servicio.
- `*-service.yaml`: servicios internos `ClusterIP` para comunicacion dentro del cluster.
- `ingress.yaml`: entrada HTTP mediante AWS Load Balancer Controller y Application Load Balancer.
- `hpa.yaml`: escalado horizontal por uso de CPU.
- `kustomization.yaml`: agrupacion de manifiestos para aplicar el stack completo.

## Requisitos previos

- Cluster EKS creado por Terraform.
- Repositorios ECR creados y con imagenes publicadas.
- `kubectl` configurado contra el cluster.
- AWS Load Balancer Controller instalado en el cluster para procesar el Ingress.
- Metrics Server instalado para que los HPA puedan leer metricas de CPU.

## Preparacion

Actualizar el contexto de `kubectl`:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name innovatech-logistics-dev-eks
```

Crear el secreto real desde variables de entorno locales:

```bash
kubectl create namespace innovatech --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic innovatech-db-secret \
  --namespace innovatech \
  --from-literal=DB_USERNAME="$DB_USERNAME" \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
```

Aplicar la configuracion base:

```bash
kubectl apply -k k8s
```

Actualizar el `ConfigMap` con la IP privada de la base de datos entregada por Terraform:

```bash
kubectl patch configmap innovatech-config \
  --namespace innovatech \
  --type merge \
  --patch "{\"data\":{\"DB_ENDPOINT\":\"$(terraform -chdir=infra/terraform output -raw database_private_ip)\"}}"
```

## Imagenes

Los manifiestos usan placeholders para las imagenes ECR. Antes de aplicar en un ambiente real, reemplazar:

- `000000000000` por el ID real de la cuenta AWS.
- `us-east-1` por la region real si cambia el ambiente.

Ejemplo:

```bash
kubectl set image deployment/frontend-despachos \
  frontend-despachos=381492057938.dkr.ecr.us-east-1.amazonaws.com/innovatech-logistics-dev-frontend-despachos:latest \
  --namespace innovatech
```

El pipeline CI/CD debe automatizar este reemplazo durante la fase de despliegue.

## Verificacion

Verificar estado:

```bash
kubectl get pods,svc,ingress,hpa -n innovatech
kubectl rollout status deployment/frontend-despachos -n innovatech
kubectl rollout status deployment/api-despachos -n innovatech
kubectl rollout status deployment/api-ventas -n innovatech
```

## Limpieza

Eliminar los recursos de aplicacion:

```bash
kubectl delete -k k8s
```

La infraestructura AWS se elimina desde Terraform con `terraform destroy`.
