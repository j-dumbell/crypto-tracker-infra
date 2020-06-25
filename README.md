# crypto-tracker-infra
This repo contains the terraform code for provisioning the crypto-tracker infrastructure.
## First time setup
#### Auth
To setup GCP authentication (where `<creds_path>` is the path to the credentials json file):

```export GOOGLE_APPLICATION_CREDENTIALS="<creds_path>"```

#### Set DB password
Create a secret in GCP Secret manager with key `PGPASSWORD` to hold the database password.

#### Provision Backend
Update the variables in `remote_state/main.tf` as per the GCP project.

Run `make remote-state` to create the remote state GCS bucket.

#### Provision environments
`make init env=<env>` (where `<env>` is `prod` or `staging`) to initialize terraform.

`make plan env=<env>` to plan provisioning.

`make apply env=<env>` to provision resources.

