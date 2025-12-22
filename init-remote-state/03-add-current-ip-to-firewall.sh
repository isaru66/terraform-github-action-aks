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

# Verify access to storage account with retry logic
echo "Verifying access to Terraform state storage..."
MAX_RETRIES=5
RETRY_COUNT=0
ACCESS_GRANTED=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  echo "Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES..."
  
  # Try to list containers to verify access
  if az storage container list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --auth-mode login \
    --output none 2>/dev/null; then
    echo "Access verified - Successfully connected to storage account $STORAGE_ACCOUNT_NAME"
    ACCESS_GRANTED=true
    break
  fi
  
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
    echo "Access not yet available, waiting 2 seconds before retry..."
    sleep 2
  fi
done

if [ "$ACCESS_GRANTED" = false ]; then
  echo "Warning: Could not access storage account after $MAX_RETRIES attempts"
  echo "The firewall rule may still be propagating. Please verify manually if needed."
  exit 1
fi

echo "IP successfully added to storage account firewall rules"
