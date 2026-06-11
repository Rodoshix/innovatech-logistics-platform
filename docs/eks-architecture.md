# Arquitectura objetivo EKS

Este documento define la arquitectura objetivo de Kubernetes para Innovatech Logistics Platform sobre AWS.

## Objetivo

Migrar la capa de ejecucion de aplicaciones desde un modelo basado en servicio de contenedores hacia un modelo de orquestacion Kubernetes usando Amazon EKS, manteniendo los principios DevOps ya presentes en la plataforma:

- Imagenes de contenedor publicadas en Amazon ECR.
- Infraestructura administrada con Terraform.
- Entrega automatizada mediante GitHub Actions.
- Entrada publica mediante Application Load Balancer.
- Capas de aplicacion y base de datos privadas.
- Workloads observables mediante logs, metricas y estado de despliegue.

## Arquitectura objetivo

```text
Usuario
  |
  v
Application Load Balancer
  |
  v
Amazon EKS Cluster
  |
  +-- Deployment frontend-despachos
  |     +-- Service frontend-despachos
  |
  +-- Deployment api-despachos
  |     +-- Service api-despachos
  |
  +-- Deployment api-ventas
        +-- Service api-ventas

Runtime MySQL
  |
  v
Instancia EC2 privada con volumen Docker
```

## Componentes de plataforma

| Componente | Responsabilidad |
| --- | --- |
| Amazon EKS | Plano de control Kubernetes para orquestacion de aplicaciones. |
| Managed node group | Capacidad de ejecucion para los pods de aplicacion. |
| Amazon ECR | Registro privado para imagenes de aplicacion. |
| Kubernetes Deployments | Estado deseado y gestion de rollouts por servicio. |
| Kubernetes Services | DNS interno estable y enrutamiento entre pods. |
| Kubernetes Ingress | Entrada HTTP publica mediante balanceo AWS. |
| Horizontal Pod Autoscaler | Escalamiento horizontal de pods basado en metricas. |
| CloudWatch | Evidencia operacional de logs y metricas. |
| Terraform | Provisionamiento y ciclo de vida de infraestructura. |
| GitHub Actions | Automatizacion de build, push y deploy. |

## Workloads de aplicacion

| Workload | Origen de imagen | Puerto interno | Exposicion |
| --- | --- | --- | --- |
| `frontend-despachos` | Amazon ECR | `8082` | Publico mediante Ingress/ALB |
| `api-despachos` | Amazon ECR | `8080` | Service interno Kubernetes |
| `api-ventas` | Amazon ECR | `8081` | Service interno Kubernetes |
| `mysql` | Docker sobre EC2 | `3306` | Solo red privada |

## Modelo de red

El diseno objetivo mantiene la misma direccion de seguridad ya usada por la plataforma:

- Las subnets publicas alojan recursos de entrada publica.
- Las subnets privadas alojan nodos de Kubernetes o networking privado de pods.
- MySQL permanece privado y acepta trafico solo desde la capa de aplicacion.
- Internet llega unicamente al punto de entrada HTTP.
- Las APIs no se exponen directamente a Internet.

## Enrutamiento Kubernetes

El frontend se mantiene como punto de entrada publico para los usuarios. Las APIs backend se consumen mediante Services internos de Kubernetes.

Nombres de servicio esperados:

```text
frontend-despachos
api-despachos
api-ventas
```

El runtime Nginx del frontend debe apuntar a nombres DNS internos de Kubernetes:

```text
api-despachos:8080
api-ventas:8081
```

Esto cambia respecto del modelo anterior basado en ECS, donde los contenedores compartian la red de una misma task y podian comunicarse mediante `127.0.0.1`.

## Estrategia de autoscaling

El mecanismo de escalamiento de Kubernetes sera Horizontal Pod Autoscaler.

Politica inicial:

| Workload | Replicas minimas | Replicas maximas | Metrica objetivo |
| --- | ---: | ---: | --- |
| `frontend-despachos` | 1 | 2 | Uso de CPU |
| `api-despachos` | 1 | 2 | Uso de CPU |
| `api-ventas` | 1 | 2 | Uso de CPU |

El valor maximo inicial es conservador para mantener el entorno controlado y eficiente en costo. Puede aumentarse posteriormente si la plataforma requiere mayor capacidad.

## Direccion CI/CD

El pipeline de entrega debe consolidarse como un flujo visible para el runtime Kubernetes:

```text
Checkout
  -> Build Docker images
  -> Push images to Amazon ECR
  -> Configure AWS and kubeconfig
  -> Apply Kubernetes manifests
  -> Wait for rollout
  -> Print public endpoint
```

El workflow debe exponer nombres de pasos claros y resumenes de despliegue para que la evidencia de build, push y deploy pueda revisarse directamente desde GitHub Actions.

## Observabilidad

La plataforma debe entregar evidencia de:

- Estado de pods.
- Estado de rollouts.
- Endpoint de Ingress o balanceador.
- Logs de aplicacion.
- Estado del HPA.
- Tiempo de ejecucion del pipeline.

Comandos base esperados durante validacion:

```bash
kubectl get nodes
kubectl get pods -n innovatech
kubectl get svc -n innovatech
kubectl get ingress -n innovatech
kubectl get hpa -n innovatech
kubectl logs -n innovatech deploy/frontend-despachos
kubectl rollout status deployment/frontend-despachos -n innovatech
```

La guia operativa de comandos y validaciones del cluster se mantiene en `docs/eks-operations.md`.

## Add-ons operativos

El cluster requiere dos add-ons para completar el flujo Kubernetes:

| Add-on | Uso | Instalacion |
| --- | --- | --- |
| AWS Load Balancer Controller | Convierte el `Ingress` de Kubernetes en un Application Load Balancer administrado por AWS. | Helm chart `eks/aws-load-balancer-controller`. |
| Metrics Server | Expone metricas de recursos para HPA. | Manifiesto oficial de Metrics Server. |

La instalacion se mantiene idempotente desde `scripts/eks/install-addons.sh` y tambien forma parte del workflow `EKS Delivery` antes de aplicar los manifiestos de aplicacion.

Por restriccion del entorno, no se crean roles IAM nuevos. El controller se instala usando el rol disponible en los nodos EKS. Si el entorno limita permisos de balanceadores, el diagnostico debe revisarse en los eventos del `Ingress` y logs del controller.

## Decisiones

### Usar EKS como capa de orquestacion

EKS entrega un plano de control Kubernetes administrado y alinea la plataforma con un modelo de orquestacion portable basado en recursos estandar de Kubernetes.

### Mantener ECR como registro de imagenes

El proyecto ya publica imagenes en ECR. Mantener ECR evita introducir otro registro y conserva la ruta de entrega dentro de AWS.

### Mantener MySQL fuera de Kubernetes inicialmente

La base de datos permanece en una instancia EC2 privada con persistencia mediante volumen Docker. Esto mantiene la migracion Kubernetes enfocada primero en servicios de aplicacion stateless y evita riesgo innecesario de migracion de datos.

### Usar Services internos para comunicacion backend

El trafico hacia APIs debe usar nombres DNS internos de Kubernetes. Esto es mas apropiado para Kubernetes que depender de networking local de una task.

### Usar HPA para escalamiento de aplicaciones

Horizontal Pod Autoscaler entrega comportamiento nativo de escalamiento Kubernetes y evidencia clara mediante `kubectl get hpa`.

### Instalar add-ons de cluster desde el flujo operativo

Los add-ons se instalan desde scripts y CI/CD para mantener la infraestructura Terraform enfocada en red, EKS, nodos, ECR y runtime base. Esta separacion evita agregar recursos IAM no permitidos y mantiene los complementos Kubernetes cerca de los manifiestos de aplicacion.

## Plan de migracion

1. Agregar recursos Terraform para la base EKS.
2. Agregar manifiestos Kubernetes para namespace, deployments, services, ingress y HPA.
3. Ajustar configuracion runtime para DNS interno de Kubernetes.
4. Reemplazar el flujo de despliegue ECS por un workflow de despliegue Kubernetes.
5. Validar publicacion de imagenes en ECR.
6. Validar rollout, endpoint, logs y estado de autoscaling.
7. Actualizar documentacion operativa final.

## Puntos abiertos

- Validar en ejecucion real que el rol del laboratorio permita al AWS Load Balancer Controller crear y administrar el ALB.
- Confirmar en ejecucion real que Metrics Server entregue metricas al HPA.
- Ajustar limites de CPU/memoria si los nodos EKS muestran presion de recursos durante las pruebas.
