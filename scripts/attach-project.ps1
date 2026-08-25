param(
  [Parameter(Mandatory = $true)]
  [string] $ProjectPath,

  [string] $FeatureDocumentRoot = 'docs/features'
)

$ErrorActionPreference = 'Stop'
$resolvedProject = (Resolve-Path -LiteralPath $ProjectPath).Path
$gitRoot = (& git -C $resolvedProject rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0) {
  throw "Project is not inside a Git worktree: $resolvedProject"
}

$entryPoints = @()
foreach ($name in @('AGENTS.md', 'CLAUDE.md')) {
  if (Test-Path -LiteralPath (Join-Path $resolvedProject $name)) {
    $entryPoints += $name
  }
}
$overlayPath = Join-Path $resolvedProject '.harness'
$hasOverlayFiles = (Test-Path -LiteralPath $overlayPath) -and (@(Get-ChildItem -LiteralPath $overlayPath -File -Recurse).Count -gt 0)
$deploymentMode = if ($hasOverlayFiles) { 'project-overlay' } else { 'external-global' }

[ordered]@{
  projectRoot = $resolvedProject
  gitRoot = $gitRoot.Trim()
  entryPoints = $entryPoints
  deploymentMode = $deploymentMode
  projectOverlayRequired = $false
  featureDocumentRoot = $FeatureDocumentRoot
  runtimeState = 'orca-owned'
  durableOrchestrationHistory = $false
} | ConvertTo-Json -Depth 5
