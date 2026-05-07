#!!! i should remove agent
k3d cluster create smhahS -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --servers 1 --wait
# Set namespace
kubectl config set-context --current --namespace=argocd

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Disable HTTPS redirect (very important for local)
kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge -p '{"data":{"server.insecure": "true"}}'

# Restart ArgoCD server
kubectl -n argocd rollout restart deployment argocd-server

# Apply Argocd-ingress
kubectl -n argocd apply -f /shared/config/argocd-ingress.yaml 

#retreive argocd-admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo