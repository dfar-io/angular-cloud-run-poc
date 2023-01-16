# angular-cloud-run-poc
POC of running an Angular app in GCP's Cloud Run

## Steps

### Setting up Infrastructure

1. Set up GCP Project
2. Update tf/main.tf with your project ID.
3. Enable Cloud Run Admin API (https://console.developers.google.com/apis/api/run.googleapis.com/overview)
4. Generate infrastructure
```
gcloud auth application-default login
terraform init
terraform apply
```

### Creating Angular App/Node Server

1. Create new app from Angular CLI `ng new your-app`
2. Create `index.js`
3. `npm ci && npm run build`
4. `node index.js`

### Creating Dockerfile/Deploying

1. Create Dockerfile
2. Create .github/workflows/cicd.yml
3. Create Github Actions Service Account with `Cloud Run Admin` and `Service Usage Admin`
4. Get JSON Key, format using `cat credentials.json | jq -r tostring`
5. Add GCP_SERVICE_ACCOUNT_JSON_DEV to Repo secrets

## Reference

[Reference](https://medium.com/@larry_nguyen/how-to-deploy-angular-application-on-google-cloud-run-c6d472e07bd5)