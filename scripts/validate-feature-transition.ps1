param(
  [Parameter(Mandatory = $true)]
  [string] $CurrentState,

  [Parameter(Mandatory = $true)]
  [ValidateSet(
    'requirements-analysis',
    'architecture-design',
    'implementation',
    'verification-and-review',
    'branch-integration'
  )]
  [string] $TargetPhase,

  [ValidateSet('none', 'continue', 'confirm', 'approve')]
  [string] $Decision = 'none',

  [string] $RunId,
  [string] $TaskId,
  [string] $WorkflowPath
)

$ErrorActionPreference = 'Stop'
$HarnessRoot = Split-Path -Parent $PSScriptRoot
if (-not $WorkflowPath) {
  $WorkflowPath = Join-Path $HarnessRoot 'core\workflows\feature-run.json'
}

if (-not (Test-Path -LiteralPath $WorkflowPath)) {
  throw "Missing Feature Run workflow: $WorkflowPath"
}

$workflow = Get-Content -Raw -LiteralPath $WorkflowPath | ConvertFrom-Json
$phaseProperty = $workflow.phases | Where-Object { $_.id -eq $TargetPhase }
if (-not $phaseProperty) {
  throw "Missing Feature Run phase: $TargetPhase"
}

$reasons = [System.Collections.Generic.List[string]]::new()
$policy = $workflow.executionPolicy

if ($policy.requiresBoundOrcaRun -eq $true -and [string]::IsNullOrWhiteSpace($RunId)) {
  [void] $reasons.Add('bound-orca-run-required')
}

if ($policy.requiresFeatureTask -eq $true -and [string]::IsNullOrWhiteSpace($TaskId)) {
  [void] $reasons.Add('bound-feature-task-required')
}

if ($phaseProperty.workerRequired -eq $true -and $policy.requiresTaskForWorkerDispatch -eq $true -and [string]::IsNullOrWhiteSpace($TaskId)) {
  [void] $reasons.Add('bound-orca-task-required')
}

if ($phaseProperty.entry -and $CurrentState -ne $phaseProperty.entry) {
  [void] $reasons.Add("required-entry-$($phaseProperty.entry)")
}

if ($phaseProperty.requiredApproval -and $CurrentState -ne $phaseProperty.requiredApproval) {
  [void] $reasons.Add("required-state-$($phaseProperty.requiredApproval)")
}

if ($TargetPhase -eq 'implementation' -and $Decision -eq 'continue' -and $policy.genericContinuationIsNotApproval -eq $true) {
  [void] $reasons.Add('generic-continuation-is-not-design-approval')
}

$allowed = $reasons.Count -eq 0
$result = [ordered]@{
  allowed = $allowed
  currentState = $CurrentState
  targetPhase = $TargetPhase
  decision = $Decision
  runBound = -not [string]::IsNullOrWhiteSpace($RunId)
  taskBound = -not [string]::IsNullOrWhiteSpace($TaskId)
  reasons = @($reasons)
}

$result | ConvertTo-Json -Depth 5
if (-not $allowed) {
  exit 1
}
