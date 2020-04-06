How to use this repository:
1. Prepare for deploy:
    * insatll terraform
    * install helm3
    * install gcloud
    * install kubectl
    * install Terraform Helm provider
    * register domain
2. Prepare environment for k8s deploy: #TODO convert `pre_deploy.sh` scritp
``` 
    gcloud services enable storage-api.googleapis.com
    gcloud services enable cloudresourcemanager.googleapis.com
    gcloud services enable compute.googleapis.com
    gcloud services enable container.googleapis.com
    gcloud services enable iam.googleapis.com
    gcloud iam service-accounts create terraform
    gcloud projects add-iam-policy-binding [PROJECT_ID] --member "serviceAccount:terraform@[PROJECT_ID].iam.gserviceaccount.com" --role "roles/owner"
    gcloud iam service-accounts keys create key.json --iam-account terraform@[PROJECT_ID].iam.gserviceaccount.com
    
    export GOOGLE_APPLICATION_CREDENTIALS="$PWD/key.json"
    gsutil mb -l [REGION] gs://[BUCKET_NAME]
    terraform init -backend-config=bucket=[BUCKET_NAME]
```
3. Deploy k8s cluster in GKE (`terraform init/apply -var-file=terraform.tvars`):
    * set all terrafrom.tvars (for gke-cluster module)
    * use jetstack gke-cluster module
    * manually configure NAT for k8s VPC #TODO via terraform gcp ??
    * manually load web app to gcr.io #TODO via github actions
4. Deploy web app service (`terraform init/apply -var-file=terraform.tvars`):
    * add API_KEY to k8s secret from `private` directory
    * set image name and API_KEY env for deploy
5. Deploy ingress-nginx (`terraform init/apply`):
    * deploy ingress-nginx service via helm
    * create namespace for cert-manager
    * deploy cert-manager via helm
    * deploy prod-issuer via kubectl (because terraform can't use custom k8s resources yet)
    * manually cofigure dns records for domain and subdomains #TODO via terraform gcp `google_dns_record_set`
6. Deploy monitoring:
    * create monitoring namespace
    * deploy prometheus operator via helm with values.yaml for grafana
7. Deploy ingress-controller:
    * set variables with domain and subdomains (grafana, prometheus, alert manager)
    * deploy controller for web app and grafana (traffic routes, certs by cert-manager for all domains)
    * deploy controller for prometheus and alert manager with basic auth (traffic routes, certs by cert-manager for all domains)
8. Add metrics from webapp to grafana #TODO
