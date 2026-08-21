param(
  [switch] $Check
)

$ErrorActionPreference = 'Stop'
$HarnessRoot = Split-Path -Parent $PSScriptRoot
$SourceRoot = Join-Path $HarnessRoot 'skills-src'
$Targets = @(
  (Join-Path $HarnessRoot '.agents\skills'),
  (Join-Path $HarnessRoot '.claude\skills')
)

if (-not (Test-Path -LiteralPath $SourceRoot)) {
  throw "Missing skill source directory: $SourceRoot"
}

$sources = Get-ChildItem -LiteralPath $SourceRoot -Directory
foreach ($source in $sources) {
  $sourceFile = Join-Path $source.FullName 'SKILL.md'
  if (-not (Test-Path -LiteralPath $sourceFile)) {
    throw "Missing SKILL.md: $sourceFile"
  }

  foreach ($targetRoot in $Targets) {
    $targetDir = Join-Path $targetRoot $source.Name
    $targetFile = Join-Path $targetDir 'SKILL.md'

    if ($Check) {
      if (-not (Test-Path -LiteralPath $targetFile)) {
        throw "Missing mirror: $targetFile"
      }
      $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceFile).Hash
      $targetHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetFile).Hash
      if ($sourceHash -ne $targetHash) {
        throw "Mirror differs: $targetFile"
      }
    } else {
      New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
      Copy-Item -LiteralPath $sourceFile -Destination $targetFile -Force
    }
  }
}

if ($Check) {
  Write-Output 'PASS: skill mirrors are synchronized'
} else {
  Write-Output 'PASS: skill mirrors synchronized from skills-src'
}

