targetScope = 'subscription'

// Deploying the resource group and a storage account inside of it
module resourceGroup 'modules/rg-shared-platform.bicep' = {
  params: {
    environmentType: 'dev'
  }
}
