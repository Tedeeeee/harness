$ErrorActionPreference = 'Stop'
$syncScript = Join-Path $PSScriptRoot 'sync-skills.ps1'
& $syncScript -Check
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

