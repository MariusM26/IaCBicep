/*
  This file contains all the Azure RBAC Role Definition IDs used across the infrastructure.
  The roles are organized by resource category for better maintainability.
  
  Each role ID can be verified at: https://learn.microsoft.com/azure/role-based-access-control/built-in-roles
*/

@export()
@description('Microsoft Azure Role Definitions')
var roleDefinitions = {
  // Containers related role definitions
  // Used for managing access to containers and their resources
  Containers: {
    // Allows pulling container images from Azure Container Registry
    // Used by App Services and other compute resources that need to pull images
    AcrPull: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }

  // Integration service role definitions
  // Used for managing access to integration services like Service Bus
  Integration: {
    // Allows receiving messages from Service Bus queues and topics
    // Typically used by consuming applications
    ServiceBusDataReceiver: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'

    // Allows sending messages to Service Bus queues and topics
    // Typically used by publishing applications
    ServiceBusDataSender: 'f87e0ec8-304f-4258-8a6f-60c97a21a075'
  }

  // Storage related role definitions
  // Used for managing access to storage accounts and their resources
  Storage: {
    // Allows read, write, and delete access to Azure Storage blob containers and data
    // Used by applications that need full access to storage data
    StorageBlobDataContributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  }
}
