terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.2.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-isaru66-aks-terraform"
    storage_account_name = "stisaru66tfstate23197"
    container_name       = "tfstate"
    key                  = "terraform-github-action-aks.tfstate"
    # use_oidc             = true, 
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  use_oidc        = true
  subscription_id = var.subscription_id
}