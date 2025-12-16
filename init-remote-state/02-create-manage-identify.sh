#!/bin/bash

RESOURCE_GROUP_NAME=rg-isaru66-aks-terraform
REGION=southeastasia
UAMI_NAME=uami-github-terraform
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# GitHub repository details - UPDATE THESE VALUES
GITHUB_ORG="your-github-org"          # Your GitHub organization or username
GITHUB_REPO="your-repo-name"          # Your repository name
GITHUB_BRANCH="main"                  # Branch name for the federated credential

echo "Creating User-assigned Managed Identity..."
# Create user-assigned managed identity
az identity create \
  --name $UAMI_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $REGION

# Get the client ID and principal ID
CLIENT_ID=$(az identity show --name $UAMI_NAME --resource-group $RESOURCE_GROUP_NAME --query clientId -o tsv)
PRINCIPAL_ID=$(az identity show --name $UAMI_NAME --resource-group $RESOURCE_GROUP_NAME --query principalId -o tsv)

echo "User-assigned Managed Identity created:"
echo "  Name: $UAMI_NAME"
echo "  Client ID: $CLIENT_ID"
echo "  Principal ID: $PRINCIPAL_ID"

# Assign Contributor role to the managed identity for the subscription
echo "Assigning Contributor role to the managed identity..."
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Create federated credential for GitHub Actions (main branch)
echo "Creating federated credential for GitHub Actions (branch: $GITHUB_BRANCH)..."
az identity federated-credential create \
  --name "github-federated-credential-$GITHUB_BRANCH" \
  --identity-name $UAMI_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/$GITHUB_BRANCH" \
  --audiences "api://AzureADTokenExchange"

# Create federated credential for Pull Requests (optional)
echo "Creating federated credential for GitHub Actions (pull requests)..."
az identity federated-credential create \
  --name "github-federated-credential-pr" \
  --identity-name $UAMI_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:$GITHUB_ORG/$GITHUB_REPO:pull_request" \
  --audiences "api://AzureADTokenExchange"

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Add these secrets to your GitHub repository:"
echo "  AZURE_CLIENT_ID: $CLIENT_ID"
echo "  AZURE_TENANT_ID: $(az account show --query tenantId -o tsv)"
echo "  AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo ""
echo "Example GitHub Actions workflow configuration:"
echo "---------------------------------------"
cat << 'EOF'
permissions:
  id-token: write
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        run: terraform plan
EOF
echo "---------------------------------------"
