# Kubernetes Deployment Commands for AWS EKS

## Prerequisites

1. **Install kubectl**:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

2. **Configure AWS CLI**:
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your region (e.g., us-west-2)
```

3. **Update kubeconfig for your EKS cluster**:
```bash
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2
```

---

## Option 1: Quick Deploy (Using Script)

```bash
cd k8s
chmod +x deploy.sh
./deploy.sh
```

---

## Option 2: Manual Step-by-Step Deployment

### Step 1: Verify Cluster Connection
```bash
# Check cluster info
kubectl cluster-info

# List all nodes
kubectl get nodes

# Check node details
kubectl describe nodes
```

### Step 2: Install NGINX Ingress Controller
```bash
# Install NGINX Ingress Controller for AWS
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/aws/deploy.yaml

# Wait for the controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Check ingress controller status
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### Step 3: Deploy Backend Application
```bash
# Apply backend deployment (2 replicas)
kubectl apply -f backend-deployment.yaml

# Apply backend service
kubectl apply -f backend-service.yaml

# Check backend deployment status
kubectl get deployments
kubectl get pods -l app=backend
kubectl describe deployment backend-deployment
```

### Step 4: Deploy Frontend Application
```bash
# Apply frontend deployment (2 replicas)
kubectl apply -f frontend-deployment.yaml

# Apply frontend service
kubectl apply -f frontend-service.yaml

# Check frontend deployment status
kubectl get deployments
kubectl get pods -l app=frontend
kubectl describe deployment frontend-deployment
```

### Step 5: Wait for Deployments to be Ready
```bash
# Wait for backend
kubectl rollout status deployment/backend-deployment

# Wait for frontend
kubectl rollout status deployment/frontend-deployment
```

### Step 6: Deploy Ingress Resource
```bash
# Apply ingress
kubectl apply -f ingress.yaml

# Check ingress status
kubectl get ingress
kubectl describe ingress app-ingress
```

### Step 7: Get LoadBalancer URL
```bash
# Get the LoadBalancer URL (may take 2-3 minutes to provision)
kubectl get service ingress-nginx-controller -n ingress-nginx

# Get the external URL
LOADBALANCER_URL=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Your app is available at: http://${LOADBALANCER_URL}"
```

---

## Monitoring and Debugging Commands

### View All Resources
```bash
# Get all resources in default namespace
kubectl get all

# Get all resources with labels
kubectl get all --show-labels

# Get resources in all namespaces
kubectl get all --all-namespaces
```

### Check Pods
```bash
# List all pods
kubectl get pods

# List pods with more details
kubectl get pods -o wide

# Watch pods in real-time
kubectl get pods -w

# Describe a specific pod
kubectl describe pod <pod-name>

# Get logs from a pod
kubectl logs <pod-name>

# Get logs from a specific container in a pod
kubectl logs <pod-name> -c <container-name>

# Follow logs in real-time
kubectl logs -f <pod-name>

# Get logs from all backend pods
kubectl logs -l app=backend --tail=50

# Get logs from all frontend pods
kubectl logs -l app=frontend --tail=50
```

### Check Deployments
```bash
# List deployments
kubectl get deployments

# Describe deployment
kubectl describe deployment backend-deployment
kubectl describe deployment frontend-deployment

# Check deployment rollout status
kubectl rollout status deployment/backend-deployment
kubectl rollout status deployment/frontend-deployment

# View deployment history
kubectl rollout history deployment/backend-deployment
kubectl rollout history deployment/frontend-deployment
```

### Check Services
```bash
# List services
kubectl get services
kubectl get svc

# Describe a service
kubectl describe service backend-service
kubectl describe service frontend-service

# Get service endpoints
kubectl get endpoints
```

### Check Ingress
```bash
# List ingress resources
kubectl get ingress

# Describe ingress
kubectl describe ingress app-ingress

# Get ingress with details
kubectl get ingress -o wide
```

### Check NGINX Ingress Controller
```bash
# Check ingress controller pods
kubectl get pods -n ingress-nginx

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

# Check ingress controller service (LoadBalancer)
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

### Resource Usage
```bash
# Get resource usage for nodes
kubectl top nodes

# Get resource usage for pods
kubectl top pods

# Get resource usage for specific deployment
kubectl top pods -l app=backend
kubectl top pods -l app=frontend
```

### Events
```bash
# View cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

# View events for specific namespace
kubectl get events -n ingress-nginx

# Watch events in real-time
kubectl get events -w
```

---

## Scaling Commands

### Scale Deployments
```bash
# Scale backend to 3 replicas
kubectl scale deployment backend-deployment --replicas=3

# Scale frontend to 3 replicas
kubectl scale deployment frontend-deployment --replicas=3

# Check scaling status
kubectl get deployments
```

### Autoscaling (HPA)
```bash
# Create horizontal pod autoscaler for backend
kubectl autoscale deployment backend-deployment --cpu-percent=70 --min=2 --max=10

# Create horizontal pod autoscaler for frontend
kubectl autoscale deployment frontend-deployment --cpu-percent=70 --min=2 --max=10

# Check HPA status
kubectl get hpa
```

---

## Update/Rollback Commands

### Update Deployment Images
```bash
# Update backend image
kubectl set image deployment/backend-deployment backend=ghcr.io/ammarbannan/backend:new-tag

# Update frontend image
kubectl set image deployment/frontend-deployment frontend=ghcr.io/ammarbannan/frontend:new-tag

# Check rollout status
kubectl rollout status deployment/backend-deployment
kubectl rollout status deployment/frontend-deployment
```

### Rollback Deployments
```bash
# Rollback to previous version
kubectl rollout undo deployment/backend-deployment
kubectl rollout undo deployment/frontend-deployment

# Rollback to specific revision
kubectl rollout undo deployment/backend-deployment --to-revision=2
```

### Restart Deployments
```bash
# Restart deployment (rolling restart)
kubectl rollout restart deployment/backend-deployment
kubectl rollout restart deployment/frontend-deployment
```

---

## Troubleshooting Commands

### Debug Pod Issues
```bash
# Get pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # logs from previous container

# Execute commands in a pod
kubectl exec -it <pod-name> -- /bin/sh
kubectl exec -it <pod-name> -- env

# Port forward to test locally
kubectl port-forward pod/<pod-name> 8080:3000
kubectl port-forward service/backend-service 8080:80
```

### Test Service Connectivity
```bash
# Create a test pod
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- /bin/sh

# Inside the test pod, test services:
# curl http://backend-service
# curl http://frontend-service
```

### Check DNS Resolution
```bash
# Create a dnsutils pod
kubectl run dnsutils --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 --rm -it --restart=Never -- /bin/sh

# Inside the pod:
# nslookup backend-service
# nslookup frontend-service
```

---

## Cleanup Commands

### Delete Resources
```bash
# Delete ingress
kubectl delete -f ingress.yaml

# Delete frontend
kubectl delete -f frontend-service.yaml
kubectl delete -f frontend-deployment.yaml

# Delete backend
kubectl delete -f backend-service.yaml
kubectl delete -f backend-deployment.yaml

# Delete NGINX Ingress Controller
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/aws/deploy.yaml
```

### Delete Everything at Once
```bash
# Delete all resources in k8s directory
kubectl delete -f .

# Force delete if stuck
kubectl delete -f . --force --grace-period=0
```

---

## Useful Aliases (Optional)

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgi='kubectl get ingress'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
```

---

## Important Notes

1. **LoadBalancer URL**: After deployment, it may take 2-3 minutes for AWS to provision the LoadBalancer and assign a DNS name.

2. **Health Checks**: The deployments include liveness and readiness probes. Make sure your applications have a `/health` endpoint for backend and `/` for frontend.

3. **Resource Limits**: Adjust the resource requests/limits in the deployment files based on your application needs.

4. **Environment Variables**: Update the `VITE_API_URL` in the frontend deployment to match your actual backend service URL.

5. **Security**: Consider adding TLS/SSL certificates using AWS Certificate Manager and updating the ingress with TLS configuration.

6. **Monitoring**: Set up CloudWatch Container Insights for EKS to monitor your cluster:
```bash
aws eks update-cluster-config \
  --name my-eks-cluster \
  --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'
```

---

## Testing Your Deployment

Once deployed, test your application:

```bash
# Get the LoadBalancer URL
LOADBALANCER_URL=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test frontend
curl http://${LOADBALANCER_URL}/

# Test backend API
curl http://${LOADBALANCER_URL}/api

# Test with browser
echo "Open in browser: http://${LOADBALANCER_URL}"
```
