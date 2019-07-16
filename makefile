apply:
	terraform init && terraform get && \
	terraform apply -auto-approve
