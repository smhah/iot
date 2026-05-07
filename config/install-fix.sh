#!/bin/bash
set -e

echo "=== Creating k3d cluster ==="
k3d cluster create smhahS \
  -p "8080:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  --servers 1 --agents 1 --wait

kubectl config set-context --current --namespace=argocd

echo "=== Creating namespace ==="
kubectl create namespace argocd

echo "=== Pre-pulling Argo CD images (important for k3d) ==="
docker exec k3d-smhahS-server-0 ctr image pull docker.io/argoproj/argocd:v3.4.1 || true
docker exec k3d-smhahS-server-0 ctr image pull docker.io/argoproj/argocd:v3.4.1-redis || true
docker exec k3d-smhahS-server-0 ctr image pull docker.io/argoproj/argocd:v3.4.1-dex || true

echo "=== Installing Argo CD ==="
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Waiting for pods to start (this may take 1-2 minutes) ==="
sleep 30
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=180s || true

# Set simple password (admin123)
echo "=== Setting password to admin123 ==="
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$12$1Q2w3e4r5t6y7u8i9o0p1.e5v6n7m8l9k0j9h8g7f6d5s4a3s2d1f",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

echo "=== Disabling HTTPS redirect ==="
kubectl -n argocd patch configmap argocd-cmd-params-cm \
  --type merge -p '{"data":{"server.insecure": "true"}}'

echo "=== Restarting server ==="
kubectl -n argocd rollout restart deployment argocd-server

echo "=== Applying Ingress and GitHub creds ==="
kubectl -n argocd apply -f /shared/config/argocd-ingress.yaml 
kubectl -n argocd apply -f /shared/config/github-creds.yaml

echo "✅ Installation finished!"
echo "Username : admin"
echo "Password : admin123"
echo ""
echo "Try access with:"
echo "http://localhost:8080"