#!/bin/bash

RESOURCE_GROUP_NAME=rg-isaru66-aks-terraform
# STORAGE_ACCOUNT_NAME=stisaru66tfstate$RANDOM
STORAGE_ACCOUNT_NAME=stisaru66tfstate23197
CONTAINER_NAME=tfstate
REGION=southeastasia

# Create resource group
# az group create --name $RESOURCE_GROUP_NAME --location southeastasia

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --auth-mode login