param(
  [Parameter(Mandatory = $true)]
  [string] $ProjectPath,

  [Parameter(Mandatory = $true)]
  [string] $Intent,

  [string] $FeatureTitle,
  [string] $FeatureId,
  [string] $BaseBranch,
  [string] $FeatureDocumentRoot = 'docs/features',
  [string] $OrcaPath,
  [switch] $Preview
)

$ErrorActionPreference = 'Stop'
$HarnessRoot = Split-Path -Parent $PSScriptRoot
$resolvedProject = (Resolve-Path -LiteralPath $ProjectPath).Path

function Convert-ToFeatureId([string] $Value) {
  $normalized = [regex]::Replace($Value.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant(), '[^\p{L}\p{Nd}]+', '-')
  $normalized = $normalized.Trim('-')
  if ($normalized) {
    return $normalized
  }

  $bytes = [Text.Encoding]::UTF8.GetBytes($Value)
  $hash = [Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
  return 'feature-' + (($hash | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 12)
}

function Get-FirstNonEmptyLine([string] $Value) {
  foreach ($line in ($Value -split "`r?`n")) {
    if (-not [string]::IsNullOrWhiteSpace($line)) {
      return $line.Trim()
    }
  }
  return 'Feature change'
}

function Test-FastPromptOptIn([string] $Value) {
  return [regex]::IsMatch($Value, '(?i)(?<![\p{L}\p{Nd}])fast(?![\p{L}\p{Nd}])')
}

function Find-Identity([object] $Value, [string] $Prefix) {
  if ($null -eq $Value) {
    return $null
  }
  $json = $Value | ConvertTo-Json -Depth 50 -Compress
  $escapedPrefix = [regex]::Escape($Prefix)
  $pattern = '"(?:id|runId|taskId|dispatchId|worktreeId)"\s*:\s*"(' + $escapedPrefix + '[^"]*)"'
  $match = [regex]::Match($json, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($match.Success) {
    return $match.Groups[1].Value
  }
  return $null
}

function Find-PropertyValue([object] $Value, [string[]] $Names) {
  if ($null -eq $Value) {
    return $null
  }
  $json = $Value | ConvertTo-Json -Depth 50 -Compress
  foreach ($name in $Names) {
    $pattern = '"' + [regex]::Escape($name) + '"\s*:\s*"([^"]*)"'
    $match = [regex]::Match($json, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($match.Success) {
      return $match.Groups[1].Value
    }
  }
  return $null
}

function Get-OrcaResult([object] $Response) {
  if ($Response.result) {
    return $Response.result
  }
  return $Response
}

function Resolve-OrcaPath([string] $RequestedPath) {
  if ($RequestedPath) {
    return $RequestedPath
  }
  if ($env:ORCA_CLI_COMMAND) {
    return $env:ORCA_CLI_COMMAND
  }
  $command = Get-Command 'orca.exe' -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }
  $installed = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\orca\resources\bin\orca.exe'
  if (Test-Path -LiteralPath $installed) {
    return $installed
  }
  throw 'Could not resolve the Orca CLI. Set ORCA_CLI_COMMAND or pass -OrcaPath.'
}

if ([string]::IsNullOrWhiteSpace($FeatureTitle)) {
  $FeatureTitle = Get-FirstNonEmptyLine $Intent
}
if ([string]::IsNullOrWhiteSpace($FeatureId)) {
  $FeatureId = Convert-ToFeatureId $FeatureTitle
}
if ($FeatureId -notmatch '^[\p{L}\p{Nd}][\p{L}\p{Nd}-]*$') {
  throw "FeatureId must contain letters, numbers, and hyphens only: $FeatureId"
}
if ([string]::IsNullOrWhiteSpace($BaseBranch)) {
  $BaseBranch = (& git -C $resolvedProject branch --show-current).Trim()
}
if ([string]::IsNullOrWhiteSpace($BaseBranch)) {
  throw "Could not determine the current base branch: $resolvedProject"
}

$baseWorktree = (& (Join-Path $PSScriptRoot 'verify-worktree.ps1') -ProjectPath $resolvedProject -ExpectedBranch $BaseBranch -AllowDirty | ConvertFrom-Json)
$baseCommit = (& git -C $resolvedProject rev-parse "$BaseBranch^{commit}").Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($baseCommit)) {
  throw "Could not resolve the base branch commit: $BaseBranch"
}
$fastRequested = Test-FastPromptOptIn $Intent
$routeParameters = @{ Phase = 'coordinator' }
if ($fastRequested) {
  $routeParameters.Fast = $true
}
$route = (& (Join-Path $PSScriptRoot 'route-agent.ps1') @routeParameters | ConvertFrom-Json)
$derivedBranch = "orch/$FeatureId"
$featureDocument = (Join-Path $FeatureDocumentRoot "$FeatureId.md").Replace('\', '/')

$plan = [ordered]@{
  mode = if ($Preview) { 'preview' } else { 'live' }
  featureTitle = $FeatureTitle
  featureId = $FeatureId
  intent = $Intent
  projectRoot = $resolvedProject
  baseBranch = $BaseBranch
  derivedBranch = $derivedBranch
  featureDocument = $featureDocument
  coordinatorRoute = 'coordinator'
  coordinatorProvider = $route.provider
  coordinatorModel = $route.model
  coordinatorEffort = $route.effort
  fastRequested = $fastRequested
  fastApplied = $route.fastApplied
  fastUnavailable = $route.fastUnavailable
  fastCommand = $route.fastCommand
  serviceTier = $route.serviceTier
  bootstrapMode = 'automatic-from-entry-session'
  userRunsBootstrap = $false
  baseBranchSource = 'current-checked-out-branch-head'
  baseCommit = $baseCommit
  baseWorktreeClean = [bool]$baseWorktree.clean
  baseWorktreeStatus = @($baseWorktree.statusEntries)
  dirtyBasePolicy = 'fork-from-base-head-and-preserve'
  dirtyBaseChanges = 'preserved-in-base-and-excluded-from-child-worktree'
  boundRunPolicy = 'resume-existing-bound-run'
  entrySessionHandoff = 'feature-agent'
  worktreePolicy = 'one-derived-worktree-per-feature-run'
  executionMode = 'single-session'
  childTaskPolicy = 'disabled-by-default'
  runtimeOwner = 'orca'
  userConversationOwner = 'feature-agent'
  userConversationTransport = 'feature-agent-chat'
  userGateTransport = 'feature-agent-chat'
  orcaAskForUserGate = $false
  internalMessageVisibility = 'runtime-only'
  nextAction = 'Create Orca Run, Feature Task, and one Feature Agent.'
}

if ($Preview) {
  $plan | ConvertTo-Json -Depth 8
  exit 0
}

$speedPolicyScript = Join-Path $PSScriptRoot 'ensure-codex-speed-policy.ps1'
$speedPolicy = (& $speedPolicyScript | ConvertFrom-Json)
$plan.codexSpeedPolicy = $speedPolicy

$OrcaPath = Resolve-OrcaPath $OrcaPath

function Invoke-OrcaJson([string[]] $Arguments) {
  $raw = @(& $OrcaPath @Arguments 2>&1)
  try {
    $response = ($raw -join "`n") | ConvertFrom-Json
  } catch {
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
      throw "Orca command failed (exit $LASTEXITCODE): $($raw -join "`n")"
    }
    throw "Orca returned non-JSON output: $($raw -join "`n")"
  }
  if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    throw "Orca command failed (exit $LASTEXITCODE): $($raw -join "`n")"
  }
  if ($response.ok -eq $false) {
    throw "Orca rejected the command: $($response.error.message)"
  }
  return $response
}

$objective = "[$FeatureTitle] $Intent"
$runResponse = Invoke-OrcaJson @('orchestration', 'run-create', '--objective', $objective, '--json')
$runId = Find-Identity $runResponse 'run_'
if (-not $runId) {
  throw 'Orca Run was created without a readable Run ID.'
}

$featureAgentSpec = @"
You are the sole Feature Agent for '$FeatureTitle'. You are also the user-facing Coordinator for this Feature Run.

Feature ID: $FeatureId
Intent: $Intent
Requested branch label: $derivedBranch
Base branch: $BaseBranch
Base commit: $baseCommit
Base Worktree clean: $($baseWorktree.clean)
Dirty-base policy: fork the Feature Worktree from the base branch HEAD and leave all uncommitted base changes untouched and excluded from the Feature Worktree. Do not stash, reset, copy, or overwrite those changes.
Orca branch rule: the runtime may add an owner/account prefix; accept the actual branch when its final path segment equals Feature ID and it is the Worktree created for this Run. Reuse that actual branch on resume; do not create a second Worktree for a prefix difference.
Feature document: $featureDocument
Fast mode requested: $fastRequested
Fast mode applied to Coordinator: $($route.fastApplied)

Own the user conversation and the Feature Run from requirements through branch integration. You are the only Coordinator. Do not create child agents, specialist terminals, phase Tasks, or Dispatches for ordinary work. Read the Skill that matches the current phase, explain what you found, and ask the user only when a material decision is needed. Do not modify product files during requirements or design. Implementation starts after the design is explained and approved. Report the current phase and next step in plain language.

Skill routing: requirements-analysis uses requirements-analysis plus project architecture, affected domain Skills, and test; architecture-design uses architecture-design plus project architecture and affected domain Skills; implementation uses implementation plus affected backend/frontend/crawler and test; verification uses verification-and-review and test; branch-integration uses branch-integration and test. Read only the current phase and affected boundaries.

User gates belong to this Coordinator's ordinary assistant response. Explain the current behavior, impact, recommendation, alternatives, and uncertainty before asking a focused question. A requirements confirmation permits design analysis but never approves implementation. A generic continue/proceed message is not design approval. Do not send internal Orca messages to the user.

Provider fallback: Claude Opus 5 is primary. Switch to Codex only after an actual quota or provider-availability failure, preserving this Run, Task, Worktree, branch, and current feature document. Do not create a second Worktree or switch providers because the task is slow or simple.

Fast policy: Fast is disabled unless the original Feature Run intent contained the standalone marker 'fast'. If requested, send the configured runtime toggle command only to routes that advertise fastCommand. If a route has no fastCommand, report the unsupported route and ask; do not silently substitute a provider, model, or effort. Fast changes service tier, not reasoning effort.
"@

$taskResponse = Invoke-OrcaJson @('orchestration', 'task-create', '--run', $runId, '--spec', $featureAgentSpec, '--task-title', "Feature Agent: $FeatureTitle", '--display-name', "Feature · $FeatureTitle", '--json')
$featureTaskId = Find-Identity (Get-OrcaResult $taskResponse) 'task_'
if (-not $featureTaskId) {
  throw 'Feature Task was created without a readable Task ID.'
}

$workerArguments = @(
  'orchestration', 'worker-start',
  '--run', $runId,
  '--task', $featureTaskId,
  '--worktree', 'new-child',
  '--name', $FeatureId,
  '--repo', "path:$resolvedProject",
  '--base-branch', $BaseBranch,
  '--agent', $route.provider,
  '--model', $route.model,
  '--setup', 'run',
  '--display-name', "Feature · $FeatureTitle",
  '--comment', "Harness single-session Feature Agent for $FeatureId",
  '--json'
)
$workerArguments = @($workerArguments | Where-Object { $null -ne $_ -and $_ -ne '' })
if ($route.effort) {
  $workerArguments = @($workerArguments[0..($workerArguments.Count - 2)] + @('--effort', $route.effort, '--json'))
}
try {
  $workerResponse = Invoke-OrcaJson $workerArguments
  $workerResult = Get-OrcaResult $workerResponse
} catch {
  throw
}
$plan.mode = 'started'
$plan.Remove('nextAction')
$plan.runId = $runId
$plan.featureTaskId = $featureTaskId
$plan.coordinatorTaskId = $featureTaskId
$plan.dispatchId = Find-Identity $workerResult 'ctx_'
$plan.worktreeId = Find-PropertyValue $workerResult @('worktreeId')
$featureAgentTerminal = Find-PropertyValue $workerResult @('agentTerminalHandle', 'terminalHandle', 'handle')
$plan.featureAgentTerminal = $featureAgentTerminal
if ($fastRequested) {
  if (-not $route.fastCommand) {
    throw "Fast was requested, but the Coordinator route has no runtime toggle command."
  }
  if (-not $featureAgentTerminal) {
    throw 'Fast was requested, but Orca did not return the Feature Agent terminal handle.'
  }
  $fastToggleResponse = Invoke-OrcaJson @('terminal', 'send', '--terminal', $featureAgentTerminal, '--text', $route.fastCommand, '--enter', '--json')
  $plan.fastToggle = Get-OrcaResult $fastToggleResponse
}
$plan.workerReceipt = $workerResult
$plan | ConvertTo-Json -Depth 12
