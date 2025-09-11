param location string
param subnetId string

targetScope = 'subscription'

resource backofficeRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-dev-backoffice'
  location: location
}

module serviceBus '../resources/services/r-serviceBus.bicep' = {
  scope: backofficeRG
  params: {
    location: location
  }
}

module storageAccount '../resources/services/r-storageAccount.bicep' = {
  scope: backofficeRG
  params: {
    location: location
  }
}

module appService '../resources/services/r-appService.bicep' = {
  scope: backofficeRG
  params: {
    // App Service Plan params
    appServicePlanName: 'asp-dev-backoffice'
    appServicePlanKind: 'windows'
    appServicePlanSku: 'S3'
    appServicePlanSkuCapacity: 1
    appServiceName: 'as-dev-backoffice'
    appServiceLocation: location
    appServiceKind: 'app'
    subnetId: subnetId
  }
}
