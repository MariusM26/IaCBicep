@allowed([
  'dev'
  'test'
  'production'
])
param environmentType string

@allowed([
  'WestEurope'
  'UkSouth'
])
param location string
