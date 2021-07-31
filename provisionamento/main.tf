terraform{
  required_providers {
    aruzerm = {
      source = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

#Configuração Conexão Microsoft Azure
provider "azurerm" {
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
    features {}
}
#Criação Grupo de Recursos e Localização
resource "azurerm_resource_group" "terraformrg" {
  name     = "terraform-unyleya"
  location = "eastus"
}
#Criação Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space     = ["10.0.0.0/24"]
  location            = azurerm_resource_group.terraformrg.location
  resource_group_name = azurerm_resource_group.terraformrg.name  
}
#Criação Sub-Rede
resource "azurerm_subnet" "integrationsubnet" {
  name                 = "integrationsubnet"
  resource_group_name  = azurerm_resource_group.terraformrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
#Criação IP Publico AzureRM
resource "azurerm_public_ip" "terraformpublicip" {
  name                = "APP"
  location            = azurerm_resource_group.terraformrg.location
  resource_group_name = azurerm_resource_group.terraformrg.name
  allocation_method   = "Dynamic"
}
resource "azurerm_app_service_plan" "appplanunyleya" {
  name                = "unyleya-appserviceplan"
  location            = azurerm_resource_group.terraformrg.location
  resource_group_name = azurerm_resource_group.terraformrg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}
#Criação App Service
resource "azurerm_app_service" "appserviceunyleya" {
  name                = "unyleya-app-service"
  location            = azurerm_resource_group.terraformrg.location
  resource_group_name = azurerm_resource_group.terraformrg.name
  app_service_plan_id = azurerm_app_service_plan.appplanunyleya.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }

}