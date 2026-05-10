#!/bin/bash

# Configuration
GITLAB_URL="http://192.168.56.120.nip.io:8080" # Use your VM IP and Mapped Port
TOKEN="glpat-cOCSnXi7xlRyqrlfZfUaRm86MQp1OjEH.01.0w1nbk18g"
PROJECT_NAME="smhahb"

echo "Creating public project: $PROJECT_NAME..."

curl --request POST "$GITLAB_URL/api/v4/projects" \
     --header "PRIVATE-TOKEN: $TOKEN" \
     --data "name=$PROJECT_NAME" \
     --data "visibility=public" \
     --data "initialize_with_readme=true"

echo -e "\nDone!"