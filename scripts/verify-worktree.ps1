param(
  [Parameter(Mandatory = $true)]
  [string] $ProjectPath,

  [string] $ExpectedBranch,

  [switch] $AllowDirty
)

$ErrorActionPreference = 'Stop'
$resolvedProject = (Resolve-Path -LiteralPath $ProjectPath).Path
$branch = (& git -C $resolvedProject branch --show-current).Trim()
if ($LASTEXITCODE -ne 0) {
  throw "Unable to read Git branch: $resolvedProject"
}

if ($ExpectedBranch -and $branch -ne $ExpectedBranch) {
  throw "Expected branch '$ExpectedBranch' but found '$branch'"
}

$status = @(& git -C $resolvedProject status --porcelain)
if (-not $AllowDirty -and $status.Count -gt 0) {
  throw "Worktree is dirty. Review changes before starting a Feature Run."
}

[ordered]@{
  projectRoot = $resolvedProject
  branch = $branch
  clean = ($status.Count -eq 0)
  statusEntries = $status
} | ConvertTo-Json -Depth 5
