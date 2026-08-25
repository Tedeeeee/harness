[CmdletBinding()]
param(
  [string] $InstallRoot = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'personal-harness'),

  [string] $CodexSkillRoot = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.agents\skills'),

  [string] $ClaudeSkillRoot = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.claude\skills'),

  [string] $CodexInstructionPath = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex\AGENTS.md'),

  [string] $ClaudeInstructionPath = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.claude\CLAUDE.md'),

  [string] $ClaudeSettingsPath = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.claude\settings.json'),

  [switch] $UpdateOwned
)

$ErrorActionPreference = 'Stop'
$HarnessRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

function Get-AbsolutePath([string] $Path) {
  return [System.IO.Path]::GetFullPath($Path)
}

function Get-FileHashValue([string] $Path) {
  return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Copy-OwnedFile([string] $Source, [string] $Destination, [switch] $AllowUpdate) {
  $parent = Split-Path -Parent $Destination
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  if (Test-Path -LiteralPath $Destination) {
    if ((Get-FileHashValue $Source) -eq (Get-FileHashValue $Destination)) {
      return 'unchanged'
    }
    if (-not $AllowUpdate) {
      throw "Refusing to overwrite a different global Harness file: $Destination. Use -UpdateOwned after review."
    }
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    return 'updated'
  }

  Copy-Item -LiteralPath $Source -Destination $Destination
  return 'added'
}

function Copy-OwnedTree([string] $SourceRoot, [string] $DestinationRoot, [switch] $AllowUpdate) {
  $counts = [ordered]@{ added = 0; updated = 0; unchanged = 0 }
  foreach ($sourceFile in @(Get-ChildItem -LiteralPath $SourceRoot -File -Recurse)) {
    $relative = $sourceFile.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
    $destination = Join-Path $DestinationRoot $relative
    $result = Copy-OwnedFile -Source $sourceFile.FullName -Destination $destination -AllowUpdate:$AllowUpdate
    $counts[$result]++
  }
  return $counts
}

function Write-OwnedText([string] $Destination, [string] $Text, [switch] $AllowUpdate) {
  $parent = Split-Path -Parent $Destination
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  if (Test-Path -LiteralPath $Destination) {
    if ((Get-Content -Raw -LiteralPath $Destination) -eq $Text) {
      return 'unchanged'
    }
    if (-not $AllowUpdate) {
      throw "Refusing to overwrite a different global Harness file: $Destination. Use -UpdateOwned after review."
    }
    [System.IO.File]::WriteAllText($Destination, $Text, [System.Text.UTF8Encoding]::new($false))
    return 'updated'
  }

  [System.IO.File]::WriteAllText($Destination, $Text, [System.Text.UTF8Encoding]::new($false))
  return 'added'
}

function Write-InstructionBridge([string] $Destination, [string] $Bridge, [switch] $AllowUpdate) {
  $parent = Split-Path -Parent $Destination
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  $startMarker = '<!-- personal-harness:start -->'
  $endMarker = '<!-- personal-harness:end -->'
  $bridgeText = $Bridge.TrimEnd("`r", "`n")
  $existing = if (Test-Path -LiteralPath $Destination) { Get-Content -Raw -LiteralPath $Destination } else { '' }
  $startIndex = $existing.IndexOf($startMarker, [System.StringComparison]::Ordinal)
  $endIndex = if ($startIndex -ge 0) { $existing.IndexOf($endMarker, $startIndex, [System.StringComparison]::Ordinal) } else { -1 }

  if ($startIndex -ge 0 -or $endIndex -ge 0) {
    if ($startIndex -lt 0 -or $endIndex -lt $startIndex) {
      throw "Found an incomplete Personal Harness bridge in $Destination"
    }
    $existingBridge = $existing.Substring($startIndex, $endIndex + $endMarker.Length - $startIndex)
    if ($existingBridge -eq $bridgeText) {
      return 'unchanged'
    }
    if (-not $AllowUpdate) {
      throw "Refusing to overwrite a different Personal Harness bridge: $Destination. Use -UpdateOwned after review."
    }
    $updated = $existing.Substring(0, $startIndex) + $bridgeText + $existing.Substring($endIndex + $endMarker.Length)
    [System.IO.File]::WriteAllText($Destination, $updated, [System.Text.UTF8Encoding]::new($false))
    return 'updated'
  }

  $separator = if ([string]::IsNullOrEmpty($existing) -or $existing.EndsWith("`r`n") -or $existing.EndsWith("`n")) { '' } else { [Environment]::NewLine }
  [System.IO.File]::WriteAllText($Destination, "$existing$separator$bridgeText$([Environment]::NewLine)", [System.Text.UTF8Encoding]::new($false))
  return 'added'
}

function Remove-ClaudePersonalHooks([string] $Destination) {
  $settings = if (Test-Path -LiteralPath $Destination) {
    try {
      Get-Content -Raw -LiteralPath $Destination | ConvertFrom-Json
    } catch {
      throw "Claude settings are not valid JSON: $Destination"
    }
  } else {
    [pscustomobject]@{}
  }

  $removed = 0
  if ($null -eq $settings.hooks) {
    return [pscustomobject]@{ changed = $false; removed = 0 }
  }

  foreach ($eventProperty in @($settings.hooks.PSObject.Properties)) {
    $remainingGroups = @()
    foreach ($group in @($eventProperty.Value)) {
      $remainingHooks = @()
      foreach ($hook in @($group.hooks)) {
        if ([string]$hook.command -like '*personal-entry-hook.ps1*') {
          $removed++
        } else {
          $remainingHooks += $hook
        }
      }

      if ($remainingHooks.Count -gt 0) {
        $group.hooks = $remainingHooks
        $remainingGroups += $group
      }
    }

    if ($remainingGroups.Count -gt 0) {
      $eventProperty.Value = $remainingGroups
    } else {
      $settings.hooks.PSObject.Properties.Remove($eventProperty.Name)
    }
  }

  if ($removed -eq 0) {
    return [pscustomobject]@{ changed = $false; removed = 0 }
  }

  $parent = Split-Path -Parent $Destination
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  [System.IO.File]::WriteAllText($Destination, ($settings | ConvertTo-Json -Depth 20), [System.Text.UTF8Encoding]::new($false))
  return [pscustomobject]@{ changed = $true; removed = $removed }
}

$InstallRoot = Get-AbsolutePath $InstallRoot
$CodexSkillRoot = Get-AbsolutePath $CodexSkillRoot
$ClaudeSkillRoot = Get-AbsolutePath $ClaudeSkillRoot
$CodexInstructionPath = Get-AbsolutePath $CodexInstructionPath
$ClaudeInstructionPath = Get-AbsolutePath $ClaudeInstructionPath
$ClaudeSettingsPath = Get-AbsolutePath $ClaudeSettingsPath
$dataRoots = @('core', 'rules', 'templates', 'adapters', 'scripts')
$summary = [ordered]@{
  mode = 'external-global'
  harnessRoot = $HarnessRoot
  installRoot = $InstallRoot
  codexSkillRoot = $CodexSkillRoot
  claudeSkillRoot = $ClaudeSkillRoot
  added = @()
  updated = @()
  unchanged = @()
}

foreach ($root in $dataRoots) {
  $counts = Copy-OwnedTree -SourceRoot (Join-Path $HarnessRoot $root) -DestinationRoot (Join-Path $InstallRoot $root) -AllowUpdate:$UpdateOwned
  if ($counts.added -gt 0) { $summary.added += "$root ($($counts.added) files)" }
  if ($counts.updated -gt 0) { $summary.updated += "$root ($($counts.updated) files)" }
  if ($counts.unchanged -gt 0) { $summary.unchanged += "$root ($($counts.unchanged) files)" }
}

$readmeResult = Copy-OwnedFile -Source (Join-Path $HarnessRoot 'README.md') -Destination (Join-Path $InstallRoot 'README.md') -AllowUpdate:$UpdateOwned
if ($readmeResult -eq 'added') { $summary.added += 'README.md' }
if ($readmeResult -eq 'updated') { $summary.updated += 'README.md' }
if ($readmeResult -eq 'unchanged') { $summary.unchanged += 'README.md' }

$sourceSkills = @(Get-ChildItem -LiteralPath (Join-Path $HarnessRoot 'skills-src') -Directory | Where-Object {
  Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
})
foreach ($sourceSkill in $sourceSkills) {
  foreach ($targetRoot in @($CodexSkillRoot, $ClaudeSkillRoot)) {
    $destination = Join-Path $targetRoot $sourceSkill.Name
    $counts = Copy-OwnedTree -SourceRoot $sourceSkill.FullName -DestinationRoot $destination -AllowUpdate:$UpdateOwned
    $label = "$([System.IO.Path]::GetFileName($targetRoot))/$($sourceSkill.Name)"
    if ($counts.added -gt 0) { $summary.added += "$label ($($counts.added) files)" }
    if ($counts.updated -gt 0) { $summary.updated += "$label ($($counts.updated) files)" }
    if ($counts.unchanged -gt 0) { $summary.unchanged += "$label ($($counts.unchanged) files)" }
  }
}

$config = [ordered]@{
  version = 1
  mode = 'external-global'
  activation = [ordered]@{
    enabled = $true
    fallback = 'project-instructions'
  }
  harnessRoot = $HarnessRoot
  installRoot = $InstallRoot
  codexSkillRoot = $CodexSkillRoot
  claudeSkillRoot = $ClaudeSkillRoot
  runtime = 'orca'
  projectOverlayRequired = $false
  durableOrchestrationHistory = $false
}
$configResult = Write-OwnedText -Destination (Join-Path $InstallRoot 'config.json') -Text ($config | ConvertTo-Json -Depth 5) -AllowUpdate:$UpdateOwned
if ($configResult -eq 'added') { $summary.added += 'config.json' }
if ($configResult -eq 'updated') { $summary.updated += 'config.json' }
if ($configResult -eq 'unchanged') { $summary.unchanged += 'config.json' }

$entrypointBridge = @'
<!-- personal-harness:start -->
## Personal Harness entrypoint

This optional block is active only when `%APPDATA%/personal-harness/config.json` (or `PERSONAL_HARNESS_ROOT`) exists, is readable, has `mode: external-global`, and has `activation.enabled: true`. If that activation config is absent or disabled, ignore this block and follow the attached project's instructions and native Skills.

When active, this user's Claude and Codex sessions use the provider-neutral Harness Core with Orca as the worktree runtime.

- On the first behavior-changing request in an unbound session, invoke the live Bootstrap from the installed Harness Core. The current checked-out branch is the base; Bootstrap creates one derived child Worktree and one Coordinator session.
- Do not ask the user to run Bootstrap, choose a model, name a Worktree, or describe the phases.
- Do not create child agents, specialist terminals, phase Tasks, or Dispatches for ordinary work. The Coordinator explains requirements, design, implementation, and verification in the same conversation.
- A dirty base Worktree is allowed. Create the child from the current base branch HEAD and leave existing uncommitted base changes untouched and outside the child.
- Explanation-only, investigation-only, and review-only requests stay read-only and do not create a Feature Worktree.
- If a session is already bound to the Feature Worktree, continue there instead of creating a nested Worktree.

Resolve the installed Harness Core from `%APPDATA%/personal-harness/config.json` or `PERSONAL_HARNESS_ROOT`; invoke its `scripts/start-feature-run.ps1` live, never `-Preview` for normal feature work.
<!-- personal-harness:end -->
'@
$codexBridgeResult = Write-InstructionBridge -Destination $CodexInstructionPath -Bridge $entrypointBridge -AllowUpdate:$UpdateOwned
$claudeBridgeResult = Write-InstructionBridge -Destination $ClaudeInstructionPath -Bridge $entrypointBridge -AllowUpdate:$UpdateOwned
$claudeHookResult = Remove-ClaudePersonalHooks -Destination $ClaudeSettingsPath
$summary.entrypointBridges = [ordered]@{
  codex = $codexBridgeResult
  claude = $claudeBridgeResult
  codexPath = $CodexInstructionPath
  claudePath = $ClaudeInstructionPath
}
$summary.claudeHooks = [ordered]@{
  settingsPath = $ClaudeSettingsPath
  status = 'disabled'
  removed = $claudeHookResult.removed
  changed = $claudeHookResult.changed
}
$summary.activation = $config.activation

$summary | ConvertTo-Json -Depth 5
