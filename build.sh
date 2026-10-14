#!/usr/bin/env bash
set -euo pipefail

cd infra
terraform init -upgrade 
terraform apply -auto-approve

cd ../ansible/
ansible-playbook vote-playbook.yml
echo " Voting Microservice is configured✔"
ansible-playbook result-playbook.yml
echo " Result Microservice is configured✔"
ansible-playbook worker-playbook.yml
echo " Worker Microservice is configured✔"
ansible-playbook db-playbook.yml
echo " Database is configured✔"