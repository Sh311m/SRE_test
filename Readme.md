This code will deploy:
    * k8s cluster in GKE
    * ingres-nginx + cert-manager (letsencrypt)
    * HelloWorld Go web application
    * Prometheus operator 
    * ServiceMonitor for metrics from web application
    * ingress-controller with routes:
        - example.com - web application
        - gr.example.com - grafana with anonym viewer access
        - prom.example.com - prometheus UI
        - alm.example.com - alertmanager UI
        
How to use this repository:
1. Prepare for deployment:
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
    mkdir private && cd private && export GOOGLE_APPLICATION_CREDENTIALS="$PWD/key.json"
    gsutil mb -l [REGION] gs://[BUCKET_NAME]
```
3. Deploy k8s cluster in GKE (``):
    * run `terraform init -backend-config=bucket=[BUCKET_NAME]`
    * set all terrafrom.tvars (for gke-cluster module)
    * `terraform init`
    * `terraform apply -var-file=terraform.tvars`
    * manually configure NAT for k8s VPC #TODO via terraform gcp ??
    * manually upload web-app image to gcr.io (for example https://github.com/Sh311m/news-demo) #TODO via github actions 
4. Deploy web app service:
    * set all terrafrom.tvars (wapp_gcr and wapp_image_name)
    * !NB API_KEY for service deploy in private dir (API_KEY of service - https://newsapi.org/)
    * `terraform init`
    * `terraform apply -var-file=terraform.tvars`
5. Deploy ingress-nginx:
    * deploy ingress-nginx service via helm
    * `terraform init`
    * `terraform apply`
    * manually cofigure dns records for domain and subdomains #TODO via terraform gcp `google_dns_record_set`
6. Deploy monitoring:
    * `terraform init`
    * `terraform apply`
    * manually apply `mon.yaml` (CRD with service monitor for wapp metrics)
7. Deploy ingress-controller:
    * manually apply `prod-issuer.yaml` (because terraform k8s provider can't deploy CRD yet)
    * set domain variable in `terrafrom.tvars`
    * `terraform init`
    * `terraform apply -var-file=terraform.tvars`
    
Global TODO:
1. Deploy k8s CRDs via terraform. Possible ways:
    * use community kubectl provider
    * convert yaml-object in helm-charts
    * ??
2. Configure github-actions for web application to automatically deploy new versions
3. Convert files in `private` directory in k8s secrets
4. Auth for prometheus/alertmanager
