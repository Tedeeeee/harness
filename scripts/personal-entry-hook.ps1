[CmdletBinding()]
param(
  [string] $ConfigPath,
  [string] $StateRoot,
  [string] $HarnessRoot,
  [string] $BootstrapScriptPath,
  [string] $InputJson
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($HarnessRoot)) {
  $HarnessRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
}

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $configuredRoot = $env:PERSONAL_HARNESS_ROOT
  if ([string]::IsNullOrWhiteSpace($configuredRoot)) {
    $configuredRoot = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'personal-harness'
  }
  $ConfigPath = Join-Path $configuredRoot 'config.json'
}

if ([string]::IsNullOrWhiteSpace($StateRoot)) {
  $StateRoot = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'personal-harness\session-state'
}

if ([string]::IsNullOrWhiteSpace($BootstrapScriptPath)) {
  $BootstrapScriptPath = Join-Path $HarnessRoot 'scripts\start-feature-run.ps1'
}

function Write-HookResult([hashtable] $Result) {
  $Result | ConvertTo-Json -Depth 8 -Compress
}

function Read-HookInput {
  $raw = if (-not [string]::IsNullOrWhiteSpace($InputJson)) { $InputJson } else { [Console]::In.ReadToEnd() }
  if ([string]::IsNullOrWhiteSpace($raw)) {
    return [pscustomobject]@{}
  }
  try {
    return $raw | ConvertFrom-Json
  } catch {
    return [pscustomobject]@{}
  }
}

function Get-SessionKey([object] $InputObject) {
  $value = $InputObject.session_id
  if ([string]::IsNullOrWhiteSpace($value)) {
    $value = $env:ORCA_TERMINAL_HANDLE
  }
  if ([string]::IsNullOrWhiteSpace($value)) {
    $value = "$($InputObject.cwd)|$env:USERNAME"
  }
  return [regex]::Replace([string]$value, '[^a-zA-Z0-9_.-]', '_')
}

function Get-StatePath([string] $SessionKey) {
  return Join-Path $StateRoot "$SessionKey.json"
}

function Read-SessionState([string] $SessionKey) {
  $path = Get-StatePath $SessionKey
  if (-not (Test-Path -LiteralPath $path)) {
    return $null
  }
  try {
    return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
  } catch {
    return $null
  }
}

function Write-SessionState([string] $SessionKey, [hashtable] $State) {
  if (-not (Test-Path -LiteralPath $StateRoot)) {
    New-Item -ItemType Directory -Path $StateRoot -Force | Out-Null
  }
  $State.updatedAt = [DateTime]::UtcNow.ToString('o')
  $State | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Get-StatePath $SessionKey) -Encoding utf8
}

function Get-Activation {
  if (-not (Test-Path -LiteralPath $ConfigPath)) {
    return $null
  }
  try {
    $config = Get-Content -Raw -LiteralPath $ConfigPath | ConvertFrom-Json
  } catch {
    return $null
  }
  if ($config.mode -ne 'external-global') {
    return $null
  }
  if ($config.activation.enabled -ne $true) {
    return $null
  }
  return $config
}

function Test-BehaviorChangingIntent([string] $Prompt) {
  if ([string]::IsNullOrWhiteSpace($Prompt)) {
    return $false
  }
  $changePattern = '(?i)(추가|수정|개선|고쳐|구현|만들|삭제|제거|반영|리팩|마이그|fix|implement|add|change|update|refactor|migrat|build|create|remove)'
  $readOnlyPattern = '(?i)(분석만|설명만|리뷰만|검토만|확인만|무엇이 문제인지|어떻게 동작하는지|why|what happened|review only|explain only)'
  if ($Prompt -notmatch $changePattern) {
    return $false
  }
  if ($Prompt -match $readOnlyPattern -and $Prompt -notmatch '(?i)(수정해|고쳐|개선해|구현해|만들어|fix|implement|update|change)') {
    return $false
  }
  return $true
}

function Test-OrcaManagedWorktree([string] $ProjectPath) {
  if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    return $false
  }
  return $ProjectPath -match '(?i)[\\/]orca[\\/]workspaces[\\/]'
}

function Get-OrcaCommand {
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
  return $null
}

function Test-BoundRun {
  $orca = Get-OrcaCommand
  if ([string]::IsNullOrWhiteSpace($orca) -or [string]::IsNullOrWhiteSpace($env:ORCA_TERMINAL_HANDLE)) {
    return $false
  }
  try {
    $output = @(& $orca orchestration run-current --from $env:ORCA_TERMINAL_HANDLE --json 2>$null)
    if ($LASTEXITCODE -ne 0) {
      return $false
    }
    $json = ($output -join "`n") | ConvertFrom-Json
    $result = if ($json.result) { $json.result } else { $json }
    return -not [string]::IsNullOrWhiteSpace([string]$result.id)
  } catch {
    return $false
  }
}

function Invoke-Bootstrap([object] $InputObject) {
  $projectPath = [string]$InputObject.cwd
  if ([string]::IsNullOrWhiteSpace($projectPath)) {
    throw 'Claude hook did not provide a project cwd.'
  }
  if (-not (Test-Path -LiteralPath $BootstrapScriptPath)) {
    throw "Harness Bootstrap script is missing: $BootstrapScriptPath"
  }

  $output = @(& $BootstrapScriptPath -ProjectPath $projectPath -Intent ([string]$InputObject.prompt) 2>&1)
  if ($LASTEXITCODE -ne 0) {
    throw (($output -join "`n").Trim())
  }
  $plan = (($output -join "`n") | ConvertFrom-Json)
  if ($plan.mode -ne 'started' -or [string]::IsNullOrWhiteSpace([string]$plan.runId) -or [string]::IsNullOrWhiteSpace([string]$plan.featureTaskId)) {
    throw 'Harness Bootstrap returned no started Run and Feature Task.'
  }
  return $plan
}

function Get-SafeError([object] $ErrorRecord) {
  $message = [string]$ErrorRecord.Exception.Message
  if ($message.Length -gt 1000) {
    return $message.Substring(0, 1000)
  }
  return $message
}

$hookInput = Read-HookInput
$activation = Get-Activation
if ($null -eq $activation) {
  exit 0
}

# Orca has already created and bound the Feature Run for child Worktrees. The
# global entry hook must not recursively Bootstrap the Feature Agent session.
if (Test-OrcaManagedWorktree ([string]$hookInput.cwd)) {
  exit 0
}

$sessionKey = Get-SessionKey $hookInput
$state = Read-SessionState $sessionKey
$eventName = [string]$hookInput.hook_event_name

if ($eventName -eq 'UserPromptSubmit') {
  if (-not (Test-BehaviorChangingIntent ([string]$hookInput.prompt))) {
    Write-SessionState $sessionKey @{ status = 'read-only'; cwd = [string]$hookInput.cwd }
    exit 0
  }

  if ($state.status -eq 'handoff') {
    Write-HookResult @{ decision = 'block'; reason = "Harness Bootstrap already handed this session to Feature Run $($state.runId). Continue in the created Feature Agent Worktree; do not start a second Run." }
    exit 0
  }
  if ($state.status -eq 'blocked' -and [string]$state.reason -notmatch '(?i)worktree is dirty|dirty base|agent_prompt_stalled') {
    Write-HookResult @{ decision = 'block'; reason = "Harness Bootstrap already blocked this session: $($state.reason). Start a new session after resolving the reported condition." }
    exit 0
  }

  if ($state.status -eq 'bound' -or (Test-BoundRun)) {
    Write-SessionState $sessionKey @{ status = 'bound'; cwd = [string]$hookInput.cwd }
    exit 0
  }

  try {
    $plan = Invoke-Bootstrap $hookInput
    Write-SessionState $sessionKey @{ status = 'handoff'; cwd = [string]$hookInput.cwd; runId = [string]$plan.runId; taskId = [string]$plan.featureTaskId; worktreeId = [string]$plan.worktreeId }
    Write-HookResult @{ decision = 'block'; reason = "Harness Bootstrap started Feature Run $($plan.runId) and Feature Task $($plan.featureTaskId). Continue in the created Feature Agent Worktree; this entry session will not work in the base Worktree." }
  } catch {
    Write-SessionState $sessionKey @{ status = 'blocked'; cwd = [string]$hookInput.cwd; reason = Get-SafeError $_ }
    Write-HookResult @{ decision = 'block'; reason = "Harness Bootstrap stopped before product work: $(Get-SafeError $_)" }
  }
  exit 0
}

if ($eventName -eq 'PreToolUse') {
  if ($state.status -eq 'bound' -or (Test-BoundRun)) {
    exit 0
  }

  $toolName = [string]$hookInput.tool_name
  $reason = if ($state.status -eq 'read-only') {
    'This session is read-only. Personal Harness permits no product tool execution for an explanation or review-only request.'
  } elseif ($state.status -eq 'blocked') {
    "Personal Harness blocked this session because Bootstrap failed: $($state.reason)"
  } else {
    'Personal Harness requires a Feature Run and verified child Worktree before tool use. Submit a behavior-changing request through the entry session first.'
  }
  Write-HookResult @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $reason } }
  exit 0
}

exit 0
