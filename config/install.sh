k3d cluster create smhahS -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --servers 1 --agents 1 --wait
-p "8888:8888@loadbalancer"
# Set namespace
kubectl config set-context --current --namespace=argocd

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
# kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

# Set simple password (admin123)
# echo "=== Setting password to admin123 ==="
# kubectl -n argocd patch secret argocd-secret \
#   -p '{"stringData": {
#     "admin.password": "$2a$12$1Q2w3e4r5t6y7u8i9o0p1.e5v6n7m8l9k0j9h8g7f6d5s4a3s2d1f",
#     "admin.passwordMtime": "'$(date +%FT%T%Z)'"
#   }}'

# Disable HTTPS redirect (very important for local)
kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge -p '{"data":{"server.insecure": "true"}}'

# Restart ArgoCD server
kubectl -n argocd rollout restart deployment argocd-server

# Apply Argocd-ingress
kubectl -n argocd apply -f /shared/config/argocd-ingress.yaml 

#Give Argo-cd access to the private github repo
kubectl -n argocd apply -f /shared/config/github-creds.yaml

# Get Argocd Server Password
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# # Apply ArgoCD Application config
# kubectl apply -f /shared/config/argocd-app-config.yaml

