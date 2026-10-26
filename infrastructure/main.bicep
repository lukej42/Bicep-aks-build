@description('Name of the Azure Container Registry')
param acrname string
@description('Location for all resources')
param location string = resourceGroup().location
@description('SKU for the Azure Container Registry')
param acrsku string = 'Basic'
@description('SSH public key for Linux admin access on AKS')
param linuxAdminPublicKey string
@description('Name of the Azure Kubernetes Service cluster')
param aksclustername string

module acrModule './modules/acr.bicep' = {
  name: 'acrDeploy'
  params: {
    acrname: acrname
    location: location
    acrsku: acrsku
  }
}

module aksModule './modules/aks.bicep' = {
  name: 'aksDeploy'
  params: {
    aksclustername: aksclustername
    location: location
    nodecount: 2
    nodesize: 'Standard_DS2_v2'
    linuxAdminUsername: 'azureuser'
    linuxAdminPublicKey: linuxAdminPublicKey
    acrName: acrModule.outputs.acrName
  }
}

output acrName string = acrModule.outputs.acrName
output aksClusterName string = aksModule.outputs.aksClusterName
