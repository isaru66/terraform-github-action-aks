#!/bin/bash

# This script removes the current IP address from Azure Storage Account network firewall rules
# Run this as a cleanup step after Terraform has finished accessing the remote state storage
# so that temporary runner IPs do not accumulate in the storage account firewall.

RESOURCE_GROUP_NAME=${AZURE_RESOURCE_GROUP_NAME:-rg-isaru66-aks-terraform}
STORAGE_ACCOUNT_NAME=${TERRAFORM_STORAGE_ACCOUNT_NAME:-stisaru66tfstate23197}

# Get current public IP
CURRENT_IP=$(curl -s https://api.ipify.org)
echo "Current IP: $CURRENT_IP"

if [ -z "$CURRENT_IP" ]; then
  echo "Warning: Could not determine current IP, skipping firewall rule removal."
  exit 0
fi

# Remove current IP from storage account network rules
echo "Removing IP $CURRENT_IP from storage account $STORAGE_ACCOUNT_NAME firewall rules..."
az storage account network-rule remove \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --ip-address $CURRENT_IP || echo "Warning: Failed to remove IP rule (it may already be gone)."

echo "Firewall cleanup complete."
