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

param logsCategories array = [
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

var metricsCategories = [
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

output logsCategories array = logsCategories
output metricsCategories array = metricsCategories
