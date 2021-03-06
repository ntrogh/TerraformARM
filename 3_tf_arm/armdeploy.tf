# Pin the provider version
provider "azurerm" {
  version = "~>2.0.0"
  features {}
}

# Variables can be overridden via commandline or variable files
variable "suffix" {
  type = string
  default = "20200318b"
}

variable "location" {
  type = string
  default = "WestEurope"
}

# Creation of App Service Plan - depends on Resource Group
resource "azurerm_app_service_plan" "myPlan" {
  name                = "hashiasp${var.suffix}"
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Creation of App Service - depends on App Service Plan and Resource Group
resource "azurerm_app_service" "myAppService" {
  name                = "hashiappsvc${var.suffix}"
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name
  app_service_plan_id = azurerm_app_service_plan.myPlan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "environment" = "dev"
  }
}

# Creation of the resource group
resource "azurerm_resource_group" "myRG" {
  name     = "hashirg${var.suffix}"
  location = var.location
}

# Deploy an ARM template
resource "azurerm_template_deployment" "myTemplate" {
  name                = "myarmtemplate-03"
  resource_group_name = azurerm_resource_group.myRG.name

  template_body       = file("${path.module}/arm_template.json")

  parameters = {
    "storageAccountType" = "Standard_GRS"
  }

  deployment_mode = "Incremental"
}

output "storageAccountName" {
  value = azurerm_template_deployment.myTemplate.outputs["storageAccountName"]
}
output "resourceID" {
  value = azurerm_template_deployment.myTemplate.outputs["resourceID"]
}
