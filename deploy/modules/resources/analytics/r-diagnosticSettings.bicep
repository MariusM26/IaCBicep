param workspaceId string
param sqlDatabaseName string

param ErrorsEnabled bool = false
param TimeoutsEnabled bool = false
param SqlInsightsEnabled bool = false
param AutomaticTuningEnabled bool = false
param QueryStoreRuntimeStatisticsEnabled bool = false
param QueryStoreWaitStatisticsEnabled bool = false
param DatabaseWaitStatisticsEnabled bool = false
param BlocksEnabled bool = false
param DeadlocksEnabled bool = false
param DevOpsOperationsAuditEnabled bool = false
param SQLSecurityAuditEventsEnabled bool = false
param BasicMetricsEnabled bool = false
param InstanceAndAppAdvancedMetricsEnabled bool = false
param WorkloadManagementMetricsEnabled bool = false

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' existing = {
  name: sqlDatabaseName
}

resource diagSqlDb 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-sql-db'
  scope: sqlDatabase
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'Errors'
        enabled: ErrorsEnabled
      }
      {
        category: 'Timeouts'
        enabled: TimeoutsEnabled
      }
      {
        category: 'SQLInsights'
        enabled: SqlInsightsEnabled
      }
      {
        category: 'AutomaticTuning'
        enabled: AutomaticTuningEnabled
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: QueryStoreRuntimeStatisticsEnabled
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: QueryStoreWaitStatisticsEnabled
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: DatabaseWaitStatisticsEnabled
      }
      {
        category: 'Blocks'
        enabled: BlocksEnabled
      }
      {
        category: 'Deadlocks'
        enabled: DeadlocksEnabled
      }
      {
        category: 'DevOpsOperationsAudit'
        enabled: DevOpsOperationsAuditEnabled
      }
      {
        category: 'SQLSecurityAuditEvents'
        enabled: SQLSecurityAuditEventsEnabled
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: BasicMetricsEnabled
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: InstanceAndAppAdvancedMetricsEnabled
      }
      {
        category: 'WorkloadManagement'
        enabled: WorkloadManagementMetricsEnabled
      }
    ]
  }
}
