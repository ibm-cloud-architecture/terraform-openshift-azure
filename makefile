apply:
	terraform init && terraform get && \
	terraform apply -auto-approve

sshbastion:
	ssh ocpadmin@`terraform output bastion_public_ip`
