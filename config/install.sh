k3d cluster create smhahS -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" -p "8888:8888@loadbalancer" --servers 1 --wait

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

# echo "Waiting for ArgoCD pods to be ready (this can take a minute)..."
# kubectl -n argocd wait --for=condition=available --timeout=300s deployment/argocd-server
# kubectl -n argocd wait --for=condition=available --timeout=300s deployment/argocd-repo-server
for deploy in argocd-server argocd-repo-server; do
    echo -n "Waiting for $deploy."
    until kubectl -n argocd rollout status deployment/$deploy --timeout=1s >/dev/null 2>&1; do
        echo -n "."
        sleep 2
    done
    echo " Done."
done
# ----------------------
#  Delete the initial secret
# kubectl -n argocd delete secret argocd-initial-admin-secret --ignore-not-found

# # 4. Set PREDEFINED PASSWORD ("password123")
# NEW_PASSWORD_HASH='$2a$10$rByptvWM56S7AD6YKW3Vhe0X/p6S.F0.OQx/h.XpPz.19yZ0V0z2m'

# echo "Applying predefined password and configuration..."
# MTIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
# kubectl -n argocd patch secret argocd-secret \
#   -p "{\"stringData\": {\"admin.password\": \"$NEW_PASSWORD_HASH\", \"admin.passwordMtime\": \"$MTIME\"}}"

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

# Apply ArgoCD Application config
kubectl apply -f /shared/config/argocd-app-config.yaml

# Add argocd admin password
kubectl patch secret argocd-secret   -n argocd   -p "{\"data\": {\"admin.password\": \"$(echo -n '$2a$10$GYWRhMltu5Y3dENNQG3cLuH19PbXSTkF1GYe654cdwdKRD5rdKaoW' | base64 | tr -d '\n')\"}}"
