[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $ProjectPath,

  [string] $BaseBranch,

  [string] $FeatureDocumentRoot = 'docs/features',

  [switch] $AllowDirty
)

$ErrorActionPreference = 'Stop'

$HarnessRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$ResolvedProject = (Resolve-Path -LiteralPath $ProjectPath).Path

function Get-FileHashValue([string] $Path) {
  return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Copy-FileWithoutConflict([string] $Source, [string] $Destination) {
  $destinationParent = Split-Path -Parent $Destination
  if (-not (Test-Path -LiteralPath $destinationParent)) {
    New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
  }

  if (Test-Path -LiteralPath $Destination) {
    if ((Get-FileHashValue $Source) -ne (Get-FileHashValue $Destination)) {
      throw "Refusing to overwrite a different attached file: $Destination"
    }
    return 'unchanged'
  }

  Copy-Item -LiteralPath $Source -Destination $Destination
  return 'added'
}

function Copy-TreeWithoutConflicts([string] $SourceRoot, [string] $DestinationRoot) {
  $counts = [ordered]@{ added = 0; unchanged = 0 }
  foreach ($sourceFile in @(Get-ChildItem -LiteralPath $SourceRoot -File -Recurse)) {
    $relative = $sourceFile.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
    $destination = Join-Path $DestinationRoot $relative
    $result = Copy-FileWithoutConflict -Source $sourceFile.FullName -Destination $destination
    $counts[$result]++
  }
  return $counts
}

function Write-TextWithoutConflict([string] $Destination, [string] $Text) {
  $destinationParent = Split-Path -Parent $Destination
  if (-not (Test-Path -LiteralPath $destinationParent)) {
    New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
  }

  if (Test-Path -LiteralPath $Destination) {
    $existing = Get-Content -Raw -LiteralPath $Destination
    if ($existing -ne $Text) {
      throw "Refusing to overwrite a different attached file: $Destination"
    }
    return 'unchanged'
  }

  [System.IO.File]::WriteAllText($Destination, $Text, [System.Text.UTF8Encoding]::new($false))
  return 'added'
}

$gitRoot = (& git -C $ResolvedProject rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0) {
  throw "Project is not inside a Git worktree: $ResolvedProject"
}
$gitRoot = $gitRoot.Trim()

$branch = (& git -C $ResolvedProject branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
  throw "Unable to determine the current project branch: $ResolvedProject"
}
if ([string]::IsNullOrWhiteSpace($BaseBranch)) {
  $BaseBranch = $branch
}
if ($branch -ne $BaseBranch) {
  throw "Expected the project to be on base branch '$BaseBranch' before attaching; found '$branch'"
}

$status = @(& git -C $ResolvedProject status --porcelain)
if (-not $AllowDirty -and $status.Count -gt 0) {
  throw 'Project worktree is dirty. Review or commit existing changes before attaching the overlay.'
}

$sourceSkills = @(
  'feature-orchestration',
  'requirements-analysis',
  'architecture-design',
  'implementation',
  'verification-and-review',
  'branch-integration'
)
$overlayRoots = @('core', 'rules', 'templates', 'adapters')
$summary = [ordered]@{
  projectRoot = $ResolvedProject
  gitRoot = $gitRoot
  baseBranch = $BaseBranch
  featureDocumentRoot = $FeatureDocumentRoot
  added = @()
  unchanged = @()
}

foreach ($root in $overlayRoots) {
  $sourceRoot = Join-Path $HarnessRoot $root
  $destinationRoot = Join-Path $ResolvedProject ".harness\$root"
  $counts = Copy-TreeWithoutConflicts -SourceRoot $sourceRoot -DestinationRoot $destinationRoot
  if ($counts.added -gt 0) { $summary.added += ".harness/$root ($($counts.added) files)" }
  if ($counts.unchanged -gt 0) { $summary.unchanged += ".harness/$root ($($counts.unchanged) files)" }
}

$readmeResult = Copy-FileWithoutConflict -Source (Join-Path $HarnessRoot 'README.md') -Destination (Join-Path $ResolvedProject '.harness\README.md')
if ($readmeResult -eq 'added') { $summary.added += '.harness/README.md' } else { $summary.unchanged += '.harness/README.md' }

foreach ($skill in $sourceSkills) {
  $sourceSkill = Join-Path $HarnessRoot "skills-src\$skill"
  foreach ($nativeRoot in @('.agents\skills', '.claude\skills')) {
    $destinationSkill = Join-Path $ResolvedProject "$nativeRoot\$skill"
    $counts = Copy-TreeWithoutConflicts -SourceRoot $sourceSkill -DestinationRoot $destinationSkill
    $label = "$nativeRoot/$skill"
    if ($counts.added -gt 0) { $summary.added += "$label ($($counts.added) files)" }
    if ($counts.unchanged -gt 0) { $summary.unchanged += "$label ($($counts.unchanged) files)" }
  }
}

$config = [ordered]@{
  version = 1
  harness = 'feature-orchestration'
  deploymentMode = 'project-overlay'
  activation = [ordered]@{
    enabled = $true
    fallback = 'project-instructions'
  }
  runtime = 'orca'
  runtimeState = 'orca-owned'
  durableOrchestrationHistory = $false
  baseBranch = $BaseBranch
  derivedBranchPattern = 'orch/{feature-id}'
  featureDocumentRoot = $FeatureDocumentRoot
  genericSkillMirrors = @('.agents/skills', '.claude/skills')
  projectSpecificSkillsPreserved = $true
}
$configPath = Join-Path $ResolvedProject '.harness\config.json'
$configResult = Write-TextWithoutConflict -Destination $configPath -Text ($config | ConvertTo-Json -Depth 5)
if ($configResult -eq 'added') { $summary.added += '.harness/config.json' } else { $summary.unchanged += '.harness/config.json' }

$summary | ConvertTo-Json -Depth 5
