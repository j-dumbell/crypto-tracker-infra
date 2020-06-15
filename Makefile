init: check-var-env
	cd project/environments/$(env) && \
	terraform init -backend=true -backend-config="prefix=$(env)" ../..

plan: check-var-env
	cd project/environments/$(env) && \
	terraform plan ../..

apply: check-var-env
	cd project/environments/$(env) && \
	terraform apply ../..

remote-state:
	cd remote_state && \
	rm -rf .terraform/ && \
	terraform init && \
	terraform plan && \
	terraform apply

check-var-%:
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1; fi
