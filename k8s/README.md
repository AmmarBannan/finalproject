# Kubernetes Deployment for AWS EKS

This directory contains all the Kubernetes manifests and deployment scripts for running the backend and frontend applications on AWS EKS with NGINX Ingress.

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│         AWS Application Load Balancer           │
│    (Created by NGINX Ingress Controller)        │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│          NGINX Ingress Controller               │
│              (in EKS Cluster)                   │
└─────────┬───────────────────────┬───────────────┘
          │                       │
          │ /api/*                │ /*
          ▼                       ▼
┌─────────────────┐      ┌─────────────────┐
│ Backend Service │      │Frontend Service │
│   (ClusterIP)   │      │   (ClusterIP)   │
└────────┬────────┘      └────────┬────────┘
         │                        │
         ▼                        ▼
┌─────────────────┐      ┌─────────────────┐
│Backend Deployment│      │Frontend Deployment│
│   (2 Replicas)   │      │   (2 Replicas)   │
│                  │      │                  │
│ Pod 1 | Pod 2    │      │ Pod 1 | Pod 2    │
└──────────────────┘      └──────────────────┘
```

## Files

- **backend-deployment.yaml** - Backend deployment with 2 replicas
- **backend-service.yaml** - Backend ClusterIP service (internal)
- **frontend-deployment.yaml** - Frontend deployment with 2 replicas
- **frontend-service.yaml** - Frontend ClusterIP service (internal)
- **ingress.yaml** - Ingress rules for routing traffic
- **nginx-ingress-install.sh** - Script to install NGINX Ingress Controller
- **deploy.sh** - Complete deployment script
- **COMMANDS.md** - Comprehensive command reference

## Quick Start

### 1. Configure AWS Credentials
```bash
aws configure
```

### 2. Update kubeconfig for your EKS cluster
```bash
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2
```

### 3. Deploy Everything
```bash
cd k8s
chmod +x deploy.sh
./deploy.sh
```

The script will:
- Configure kubectl for your EKS cluster
- Install NGINX Ingress Controller
- Deploy backend (2 replicas)
- Deploy frontend (2 replicas)
- Create services
- Set up ingress routing
- Display the LoadBalancer URL

## Manual Deployment

If you prefer to deploy step by step:

```bash
# 1. Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/aws/deploy.yaml

# 2. Deploy Backend
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

# 3. Deploy Frontend
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# 4. Deploy Ingress
kubectl apply -f ingress.yaml

# 5. Get LoadBalancer URL
kubectl get service ingress-nginx-controller -n ingress-nginx
```

## Accessing Your Application

After deployment, get the LoadBalancer URL:

```bash
LOADBALANCER_URL=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application: http://${LOADBALANCER_URL}"
echo "API: http://${LOADBALANCER_URL}/api"
```

## Verification Commands

```bash
# Check all resources
kubectl get all

# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check ingress
kubectl get ingress

# Check logs
kubectl logs -l app=backend
kubectl logs -l app=frontend

# Describe deployments
kubectl describe deployment backend-deployment
kubectl describe deployment frontend-deployment
```

## Scaling

```bash
# Scale backend
kubectl scale deployment backend-deployment --replicas=3

# Scale frontend
kubectl scale deployment frontend-deployment --replicas=3

# Check status
kubectl get deployments
```

## Updating Images

```bash
# Update backend image
kubectl set image deployment/backend-deployment backend=ghcr.io/ammarbannan/backend:new-tag

# Update frontend image
kubectl set image deployment/frontend-deployment frontend=ghcr.io/ammarbannan/frontend:new-tag

# Check rollout status
kubectl rollout status deployment/backend-deployment
kubectl rollout status deployment/frontend-deployment
```

## Troubleshooting

### Pods not starting
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Service not accessible
```bash
kubectl get svc
kubectl describe svc backend-service
kubectl get endpoints
```

### Ingress issues
```bash
kubectl get ingress
kubectl describe ingress app-ingress
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### LoadBalancer not provisioned
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
kubectl describe svc -n ingress-nginx ingress-nginx-controller
```

## Cleanup

To remove all resources:

```bash
# Delete application resources
kubectl delete -f ingress.yaml
kubectl delete -f frontend-service.yaml
kubectl delete -f frontend-deployment.yaml
kubectl delete -f backend-service.yaml
kubectl delete -f backend-deployment.yaml

# Delete NGINX Ingress Controller
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/aws/deploy.yaml
```

Or delete everything at once:
```bash
kubectl delete -f .
```

## Important Notes

1. **LoadBalancer Provisioning**: AWS takes 2-3 minutes to provision the LoadBalancer
2. **Health Checks**: Ensure your apps have health check endpoints
3. **Resource Limits**: Adjust CPU/memory limits based on your needs
4. **SSL/TLS**: For production, add TLS certificates via AWS Certificate Manager
5. **Cost**: The LoadBalancer will incur AWS charges

## Monitoring

Check CloudWatch Container Insights:
```bash
aws eks update-cluster-config \
  --name my-eks-cluster \
  --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'
```

View metrics:
```bash
kubectl top nodes
kubectl top pods
```

## For More Commands

See [COMMANDS.md](./COMMANDS.md) for a comprehensive list of kubectl commands for monitoring, debugging, and managing your deployment.
