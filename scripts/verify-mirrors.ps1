$ErrorActionPreference = 'Stop'
$HarnessRoot = Split-Path -Parent $PSScriptRoot
$syncScript = Join-Path $PSScriptRoot 'sync-skills.ps1'
& $syncScript -Check
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

$sourceRoot = Join-Path $HarnessRoot 'skills-src'
$expected = @(
  Get-ChildItem -LiteralPath $sourceRoot -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
  } | Select-Object -ExpandProperty Name
)

foreach ($targetRoot in @(
  (Join-Path $HarnessRoot '.agents\skills'),
  (Join-Path $HarnessRoot '.claude\skills')
)) {
  $actual = @(
    Get-ChildItem -LiteralPath $targetRoot -Directory | Where-Object {
      Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
    } | Select-Object -ExpandProperty Name
  )

  $stale = @($actual | Where-Object { $_ -notin $expected })
  if ($stale.Count -gt 0) {
    throw "Stale skill mirrors in $targetRoot : $($stale -join ', ')"
  }
}

Write-Output 'PASS: skill mirrors and skill names are synchronized'
