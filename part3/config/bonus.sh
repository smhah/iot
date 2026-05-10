## Stretch Volume
sudo yum install -y cloud-utils-growpart
sudo growpart /dev/sda 1
sudo xfs_growfs /
# install help using scrip from offical helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
sh get_helm.sh
helm repo add gitlab https://charts.gitlab.io/
# helm upgrade --install gitlab gitlab/gitlab   --namespace gitlab   --create-namespace   --values /shared/config/gitlab-values.yaml   --no-hooks
# helm install gitlab gitlab/gitlab \
#   -n gitlab \
#   -f /shared/config/gitlab-values.yaml 
## an upgrade after a short time fixed ostrgres redis containers:
#helm upgrade gitlab gitlab/gitlab -n gitlab --values /shared/config/gitlab-values.yaml


helm upgrade --install gitlab gitlab/gitlab \
    -n gitlab --create-namespace \
    -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
    --set global.hosts.domain=192.168.56.120.nip.io \
    --set global.hosts.externalIP=192.168.56.120 \
    --set global.hosts.https=false
    --set global.edition=ce \
    --set gitlab.migrations.resources.requests.memory=1.5Gi \
    --set gitlab.migrations.resources.limits.memory=2.5Gi \
    --timeout 600s
    

# sudo kubectl wait --for=condition=available deployments --all -n gitlab



kubectl patch ingress gitlab-registry -n gitlab -p '{"spec":{"ingressClassName":"traefik"}}'
kubectl patch ingress gitlab-minio -n gitlab -p '{"spec":{"ingressClassName":"traefik"}}'
kubectl patch ingress gitlab-kas -n gitlab -p '{"spec":{"ingressClassName":"traefik"}}'
kubectl patch ingress gitlab-webservice-default -n gitlab -p '{"spec":{"ingressClassName":"traefik"}}'

kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo

#git clone http://root:glpat-cOCSnXi7xlRyqrlfZfUaRm86MQp1OjEH.01.0w1nbk18g@gitlab.192.168.56.120.nip.io:8080/root/smhah.git mhah

# Change remote to include token
git remote set-url origin \
  https://root:glpat-cOCSnXi7xlRyqrlfZfUaRm86MQp1OjEH.01.0w1nbk18g@gitlab.192.168.56.120.nip.io:8080/root/smhah.git