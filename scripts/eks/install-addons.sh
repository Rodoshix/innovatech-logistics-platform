#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
PROJECT_NAME="${PROJECT_NAME:-innovatech-logistics}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME:-${PROJECT_NAME}-${ENVIRONMENT}-eks}"

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI is required."
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required."
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required."
  exit 1
fi

VPC_ID="${VPC_ID:-$(aws eks describe-cluster \
  --region "${AWS_REGION}" \
  --name "${EKS_CLUSTER_NAME}" \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)}"

echo "Installing EKS add-ons"
echo "Cluster: ${EKS_CLUSTER_NAME}"
echo "Region: ${AWS_REGION}"
echo "VPC: ${VPC_ID}"

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

helm repo add eks https://aws.github.io/eks-charts --force-update >/dev/null
helm repo update >/dev/null

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName="${EKS_CLUSTER_NAME}" \
  --set region="${AWS_REGION}" \
  --set vpcId="${VPC_ID}" \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --wait

kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=300s

kubectl get deployment -n kube-system metrics-server aws-load-balancer-controller
