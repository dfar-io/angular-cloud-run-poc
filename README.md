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
3. Enable Cloud Build API (https://console.developers.google.com/apis/api/cloudbuild.googleapis.com/overview)
4. `gcloud builds submit --tag gcr.io/angular-cloud-run-poc/angular-cloud-run-poc`
5. `gcloud run deploy angular-cloud-run-poc --image gcr.io/angular-cloud-run-poc/angular-cloud-run-poc --port 4200 --region us-central1 --allow-unauthenticated`
6. Test using URL provided from deploy.

## Reference

[Reference](https://medium.com/@larry_nguyen/how-to-deploy-angular-application-on-google-cloud-run-c6d472e07bd5)