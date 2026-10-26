param aksclustername string
param location string
param nodecount int
param nodesize string
param linuxAdminUsername string
param linuxAdminPublicKey string
param acrName string

// Reference existing ACR resource
resource acr 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
  name: acrName
}

resource kubernetesCluster 'Microsoft.ContainerService/managedClusters@2026-06-01' = {
  name: aksclustername
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: aksclustername
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodecount
        vmSize: nodesize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: linuxAdminPublicKey
          }
        ]
      }
    }
    enableRBAC: true
  }
}

// Built-in AcrPull Role Definition ID
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// Assign AcrPull role to AKS identity
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, kubernetesCluster.id, acrPullRoleId)
  scope: acr
  properties: {
    principalId: kubernetesCluster.identity.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}

output aksClusterName string = kubernetesCluster.name
