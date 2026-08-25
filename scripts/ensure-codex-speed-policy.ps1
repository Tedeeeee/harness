[CmdletBinding()]
param(
  [string] $ConfigPath
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $activeCodexHome = $env:CODEX_HOME
  if ([string]::IsNullOrWhiteSpace($activeCodexHome)) {
    $activeCodexHome = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
  }
  $ConfigPath = Join-Path $activeCodexHome 'config.toml'
}

$ConfigPath = (Resolve-Path -LiteralPath $ConfigPath).Path
$original = [IO.File]::ReadAllText($ConfigPath)
$updated = $original

$updated = [regex]::Replace($updated, '(?m)^(\s*service_tier\s*=\s*)"[^"]*"', '${1}"default"')
if ($updated -notmatch '(?m)^\s*service_tier\s*=') {
  $updated = 'service_tier = "default"' + [Environment]::NewLine + $updated
}

$updated = [regex]::Replace($updated, '(?m)^(\s*default-service-tier\s*=\s*)"[^"]*"', '${1}"default"')
if ($updated -notmatch '(?m)^\s*default-service-tier\s*=') {
  if ($updated -match '(?m)^\[desktop\]\s*$') {
    $desktopReplacement = '[desktop]' + [Environment]::NewLine + 'default-service-tier = "default"'
    $updated = [regex]::Replace($updated, '(?m)^\[desktop\]\s*$', $desktopReplacement, 1)
  } else {
    $updated = $updated.TrimEnd() + [Environment]::NewLine + '[desktop]' + [Environment]::NewLine + 'default-service-tier = "default"' + [Environment]::NewLine
  }
}

$changed = $updated -ne $original
if ($changed) {
  [IO.File]::WriteAllText($ConfigPath, $updated, [Text.UTF8Encoding]::new($false))
}

[ordered]@{
  configPath = $ConfigPath
  serviceTier = 'default'
  changed = $changed
} | ConvertTo-Json -Depth 3
