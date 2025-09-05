@description('The name of the key to be created in the vault')
param keyName string

@description('The name of the parent vault)')
param keyVaultName string

@description('Tipul cheii; lasă necompletat pentru a folosi implicitele modulului/fluxului')
type ktType = 'RSA' | 'RSA-HSM' | 'EC' | 'EC-HSM' | null
param keyType ktType

@allowed([128, 192, 256, 512])
param keySize int = 256

@allowed([
  'encrypt'
  'decrypt'
  'wrapKey'
  'unwrapKey'
  'sign'
  'verify'
  'import'
])
param keyOps array = []

module kvKey 'br/public:avm/res/key-vault/vault/key:0.1.0' = {
  name: 'KeyVaultKeyDeployment'
  params: {
    name: keyName
    keyVaultName: keyVaultName
    attributesEnabled: true
    kty: keyType
    keySize: keySize
    keyOps: keyOps
  }
}
