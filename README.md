
## Install Prometheous and Grafana Dashboard  
```
helm repo add grafana-charts https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

 
helm install --namespace monitoring prometheus prometheus-community/prometheus --values infra/monitoring/prometheus-values.yaml

curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/refs/heads/release-v1.3.2/website/content/en/v1.3/getting-started/getting-started-with-karpenter/grafana-values.yaml | tee grafana-values.yaml
helm install --namespace monitoring grafana grafana-charts/grafana --values grafana-values.yaml

```


## Access Prometheous and Grafana Dashboard  
```
kubectl port-forward --namespace monitoring svc/prometheus-server 9080:80
kubectl get secret --namespace monitoring grafana-d8dd69c8d-4nrnt  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl port-forward --namespace monitoring svc/grafana 3000:80
```