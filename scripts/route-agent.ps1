param(
  [Parameter(Mandatory = $true)]
  [ValidateSet(
    'coordinator',
    'feature-orchestration',
    'requirements-analysis',
    'architecture-design',
    'implementation',
    'verification-and-review',
    'branch-integration'
  )]
  [string] $Phase,

  [ValidateSet('standard', 'low', 'high')]
  [string] $Risk = 'standard',

  [switch] $Fast,

  [string] $ConfigPath
)

$ErrorActionPreference = 'Stop'
$HarnessRoot = Split-Path -Parent $PSScriptRoot
if (-not $ConfigPath) {
  $ConfigPath = Join-Path $HarnessRoot 'core\agent-routing.json'
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
  throw "Missing routing configuration: $ConfigPath"
}

$config = Get-Content -Raw -LiteralPath $ConfigPath | ConvertFrom-Json
$routeProperty = $config.routes.PSObject.Properties[$Phase]
if (-not $routeProperty) {
  throw "Missing route for phase: $Phase"
}

$route = $routeProperty.Value
$effort = $route.effort
$fastApplied = $false
$fastUnavailable = $false
$fastRequested = $Fast.IsPresent
$fastPolicy = $config.fastPolicy
if ($fastRequested -and -not $fastPolicy.explicitPromptOptIn) {
  throw 'Fast mode is disabled by the routing policy.'
}
if ($fastRequested -and $route.fastCommand) {
  $fastApplied = $true
} elseif ($fastRequested) {
  $fastUnavailable = $true
}
$overrideGroup = $config.riskOverrides.PSObject.Properties[$Risk]
if ($overrideGroup) {
  $override = $overrideGroup.Value.PSObject.Properties[$Phase]
  if ($override -and $override.Value.effort) {
    $effort = $override.Value.effort
  }
}

$result = [ordered]@{
  phase = $Phase
  risk = $Risk
  provider = $route.provider
  model = $route.model
  effort = $effort
  fastRequested = $fastRequested
  fastApplied = $fastApplied
  fastUnavailable = $fastUnavailable
  fastCommand = $route.fastCommand
  serviceTier = if ($fastRequested) { $fastPolicy.fastServiceTier } else { $fastPolicy.defaultServiceTier }
  arenaCategory = $route.arenaCategory
  arenaEvidence = $route.arenaEvidence
  snapshotPolicy = $config.source.snapshotPolicy
}

if ($route.reviewProvider) {
  $result.reviewProvider = $route.reviewProvider
  $result.reviewModel = $route.reviewModel
  $result.reviewEffort = $route.reviewEffort
}

$result | ConvertTo-Json -Depth 5
