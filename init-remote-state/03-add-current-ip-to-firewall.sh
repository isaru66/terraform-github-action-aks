#!/bin/bash

# This script adds the current IP address to Azure Storage Account network firewall rules
# This is required to allow Terraform to access the remote state storage during initialization

RESOURCE_GROUP_NAME=${AZURE_RESOURCE_GROUP_NAME:-rg-isaru66-aks-terraform}
STORAGE_ACCOUNT_NAME=${TERRAFORM_STORAGE_ACCOUNT_NAME:-stisaru66tfstate23197}

# Get current public IP
CURRENT_IP=$(curl -s https://api.ipify.org)
echo "Current IP: $CURRENT_IP"

# Add current IP to storage account network rules
echo "Adding IP $CURRENT_IP to storage account $STORAGE_ACCOUNT_NAME firewall rules..."
az storage account network-rule add \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --ip-address $CURRENT_IP

echo "Waiting for 2 seconds to ensure the rule is applied..."
sleep 2

echo "IP successfully added to storage account firewall rules"
