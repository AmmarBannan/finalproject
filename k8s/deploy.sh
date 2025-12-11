#!/bin/bash

set -e

echo "=========================================="
echo "EKS Cluster Deployment Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Configure AWS EKS
echo -e "${BLUE}Step 1: Configuring kubectl for EKS cluster...${NC}"
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2
echo -e "${GREEN}✓ Kubeconfig updated${NC}"
echo ""

# Step 2: Verify cluster connection
echo -e "${BLUE}Step 2: Verifying cluster connection...${NC}"
kubectl cluster-info
kubectl get nodes
echo -e "${GREEN}✓ Cluster connection verified${NC}"
echo ""

# Step 3: Install NGINX Ingress Controller
echo -e "${BLUE}Step 3: Installing NGINX Ingress Controller...${NC}"
echo "This will create an AWS Load Balancer"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/aws/deploy.yaml

echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s
echo -e "${GREEN}✓ NGINX Ingress Controller installed${NC}"
echo ""

# Step 4: Deploy Backend
echo -e "${BLUE}Step 4: Deploying Backend...${NC}"
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
echo -e "${GREEN}✓ Backend deployed${NC}"
echo ""

# Step 5: Deploy Frontend
echo -e "${BLUE}Step 5: Deploying Frontend...${NC}"
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
echo -e "${GREEN}✓ Frontend deployed${NC}"
echo ""

# Step 6: Wait for deployments
echo -e "${BLUE}Step 6: Waiting for deployments to be ready...${NC}"
kubectl rollout status deployment/backend-deployment --timeout=300s
kubectl rollout status deployment/frontend-deployment --timeout=300s
echo -e "${GREEN}✓ All deployments ready${NC}"
echo ""

# Step 7: Deploy Ingress
echo -e "${BLUE}Step 7: Deploying Ingress...${NC}"
kubectl apply -f ingress.yaml
echo -e "${GREEN}✓ Ingress deployed${NC}"
echo ""

# Step 8: Get LoadBalancer URL
echo -e "${BLUE}Step 8: Getting LoadBalancer URL...${NC}"
echo -e "${YELLOW}Waiting for LoadBalancer to be provisioned (this may take 2-3 minutes)...${NC}"
sleep 10

LOADBALANCER_URL=""
for i in {1..30}; do
  LOADBALANCER_URL=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ -n "$LOADBALANCER_URL" ]; then
    break
  fi
  echo "Waiting for LoadBalancer... ($i/30)"
  sleep 10
done

echo ""
echo "=========================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "=========================================="
echo ""
echo "Your application is accessible at:"
echo -e "${GREEN}http://${LOADBALANCER_URL}${NC}"
echo ""
echo "API endpoint:"
echo -e "${GREEN}http://${LOADBALANCER_URL}/api${NC}"
echo ""
echo "To check the status of your deployment, run:"
echo "  kubectl get all"
echo ""
