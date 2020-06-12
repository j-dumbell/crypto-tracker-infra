remote-state:
	cd remote_state && \
	rm -rf .terraform/ && \
	terraform init && \
	terraform apply

