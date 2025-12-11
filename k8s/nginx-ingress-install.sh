#!/bin/bash

# Install NGINX Ingress Controller for AWS EKS
# This creates a LoadBalancer service that AWS will provision with an ELB

echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/aws/deploy.yaml

echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "NGINX Ingress Controller installed successfully!"
echo ""
echo "Getting the LoadBalancer URL..."
kubectl get service ingress-nginx-controller -n ingress-nginx
