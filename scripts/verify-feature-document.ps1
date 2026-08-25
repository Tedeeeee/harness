param(
  [Parameter(Mandatory = $true)]
  [string] $ProjectPath,

  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[a-z0-9][a-z0-9-]*$')]
  [string] $FeatureId,

  [string] $FeatureDocumentRoot = 'docs/features'
)

$ErrorActionPreference = 'Stop'
$resolvedProject = (Resolve-Path -LiteralPath $ProjectPath).Path
$documentPath = Join-Path $resolvedProject (Join-Path $FeatureDocumentRoot "$FeatureId.md")
if (-not (Test-Path -LiteralPath $documentPath)) {
  throw "Missing current feature document: $documentPath"
}

$requiredHeadings = @(
  'Purpose',
  'Current behavior',
  'Flow and state',
  'Rules and edge cases',
  'Contracts',
  'Affected areas',
  'Verification'
)
$document = Get-Content -Raw -LiteralPath $documentPath
$missing = @()
foreach ($heading in $requiredHeadings) {
  $pattern = '(?m)^##\s+' + [regex]::Escape($heading) + '\s*$'
  if ($document -notmatch $pattern) {
    $missing += $heading
  }
}

if ($missing.Count -gt 0) {
  throw "Feature document is missing sections: $($missing -join ', ')"
}

[ordered]@{
  featureId = $FeatureId
  document = $documentPath
  currentStateDocument = $true
  requiredSections = $requiredHeadings
} | ConvertTo-Json -Depth 5
