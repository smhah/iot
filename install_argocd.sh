kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl config set-context --current --namespace=argocd

kubectl get svc traefik -n kube-system
kubectl get svc traefik -n kube-system -o jsonpath='{.spec.clusterIP}'
kubectl -n argocd patch configmap argocd-cmd-params-cm   --type merge -p '{"data":{"server.insecure": "true"}}'
kubectl -n argocd rollout restart deployment argocd-server
k3d cluster edit smhahS --port-add 8080:80@loadbalancer