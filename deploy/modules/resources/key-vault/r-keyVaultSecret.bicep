@description('The name of the secret to be created in Key Vault')
param secretName string

@secure()
@description('The value of the secret to be stored in Key Vault')
param secretValue string

@description('The name of the parent Key Vault)')
param keyVaultName string

@description('The content type of the secret')
param contentType string = 'text/plain'

module kvSecret 'br/public:avm/res/key-vault/vault/secret:0.1.0' = {
  name: 'KeyVaultSecretDeployment'
  params: {
    name: secretName
    keyVaultName: keyVaultName
    value: secretValue
    contentType: contentType
    attributesEnabled: true
  }
}
