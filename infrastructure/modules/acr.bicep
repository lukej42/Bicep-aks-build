param acrname string
param location string
param acrsku string

resource acr 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: acrname
  location: location
  sku: {
    name: acrsku
  }
  properties: {
    adminUserEnabled: false
  }
}

output acrName string = acr.name
output acrId string = acr.id
