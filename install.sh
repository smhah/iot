#!!! i should remove agent
k3d cluster create smhahS -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --servers 1 --wait
# Set namespace
kubectl config set-context --current --namespace=argocd

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# --- NEW WAIT LOGIC ---
echo "Waiting for ArgoCD deployments to appear..."
# Wait for the deployment to actually exist in the API before checking status
until kubectl -n argocd get deployment argocd-server > /dev/null 2>&1; do
  echo "Still waiting for argocd-server deployment..."
  sleep 2
done

echo "Waiting for ArgoCD pods to be ready (this can take a minute)..."
kubectl -n argocd wait --for=condition=available --timeout=300s deployment/argocd-server
kubectl -n argocd wait --for=condition=available --timeout=300s deployment/argocd-repo-server
# ----------------------

# 4. Set PREDEFINED PASSWORD ("password123")
NEW_PASSWORD_HASH='$2a$10$rByptvWM56S7AD6YKW3Vhe0X/p6S.F0.OQx/h.XpPz.19yZ0V0z2m'

echo "Applying predefined password and configuration..."
kubectl -n argocd patch secret argocd-secret \
  -p "{\"stringData\": {\"admin.password\": \"$NEW_PASSWORD_HASH\", \"admin.passwordMtime\": \"$(date +%FT%T%Z)\"}}"

# Disable HTTPS redirect (very important for local)
kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge -p '{"data":{"server.insecure": "true"}}'

# Restart ArgoCD server
kubectl -n argocd rollout restart deployment argocd-server

# Apply Argocd-ingress
kubectl -n argocd apply -f /shared/config/argocd-ingress.yaml 

#retreive argocd-admin password
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo