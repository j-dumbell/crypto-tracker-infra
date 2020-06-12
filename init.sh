cd project/environments/$1 && \
rm -rf .terraform/ && \
terraform init -backend=true ../..