param(
  [string] $CorePath
)

$ErrorActionPreference = 'Stop'
$HarnessRoot = Split-Path -Parent $PSScriptRoot
if (-not $CorePath) {
  $CorePath = Join-Path $HarnessRoot 'core'
}

$files = Get-ChildItem -LiteralPath $CorePath -Filter '*.json' -File -Recurse
if ($files.Count -eq 0) {
  throw "No Core JSON contracts found: $CorePath"
}

foreach ($file in $files) {
  try {
    Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json | Out-Null
  } catch {
    throw "Invalid JSON: $($file.FullName) - $($_.Exception.Message)"
  }
}

Write-Output "PASS: $($files.Count) Core JSON files are valid"
