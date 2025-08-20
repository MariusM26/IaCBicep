param location string

targetScope = 'subscription'

resource backofficeRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-dev-backoffice'
  location: location
}

module serviceBus '../resources/r-serviceBus.bicep' = {
  scope: backofficeRG
  params: {
    location: location
  }
}

module storageAccount '../resources/r-storageAccount.bicep' = {
  scope: backofficeRG
  params: {
    location: location
  }
}

module appService '../resources/r-appService.bicep' = {
  scope: backofficeRG
  params: {
    location: location
  }
}
