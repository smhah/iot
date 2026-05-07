kubectl -n argocd patch configmap argocd-cm --type merge \
  -p '{"data":{"timeout.reconciliation":"30s","timeout.reconciliation.jitter":"5s"}}'

# 1. Restart the correct workload
kubectl -n argocd rollout restart statefulset argocd-application-controller

# 2. (Optional but recommended) Also restart repo-server
kubectl -n argocd rollout restart deployment argocd-repo-server