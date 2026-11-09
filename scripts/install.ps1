# Personal harness installer (Windows PowerShell 5.1 compatible, ASCII only).
# - Removes what the old v0 personal harness installed (backed up first).
# - Links each skill in skills/ into ~/.claude/skills as a directory junction.
# - Writes a marked block into ~/.claude/CLAUDE.md that imports entry.md.
# - Reports Codex CLI and Orca readiness.
# Run again at any time; the result is the same.
param(
  [switch] $Uninstall
)

$ErrorActionPreference = 'Stop'

$HarnessRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$UserHome = [Environment]::GetFolderPath('UserProfile')
$ClaudeDir = Join-Path $UserHome '.claude'
$ClaudeSkills = Join-Path $ClaudeDir 'skills'
$ClaudeMd = Join-Path $ClaudeDir 'CLAUDE.md'
$ClaudeSettings = Join-Path $ClaudeDir 'settings.json'
$CodexAgentsMd = Join-Path $UserHome '.codex\AGENTS.md'
$AgentsSkills = Join-Path $UserHome '.agents\skills'
$OldInstallRoot = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'personal-harness'
$OldSkillNames = @(
  'architecture-design', 'branch-integration', 'feature-orchestration', 'implementation',
  'personal-orchestration', 'requirements-analysis', 'verification-and-review'
)
$StartMarker = '<!-- personal-harness:start -->'
$EndMarker = '<!-- personal-harness:end -->'
$BlockPattern = '(?s)\r?\n?' + [regex]::Escape($StartMarker) + '.*?' + [regex]::Escape($EndMarker) + '\r?\n?'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$BackupRoot = Join-Path $env:LOCALAPPDATA ('personal-harness-backup\' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '-' + $PID)
$Report = New-Object System.Collections.Generic.List[string]
$script:BackedUp = $false

function Add-Report([string] $Line) { $Report.Add($Line) | Out-Null }

function Test-Link([string] $Path) {
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if ($null -eq $item) { return $false }
  return [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Get-LinkTarget([string] $Path) {
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if ($null -eq $item -or $null -eq $item.Target) { return '' }
  return [string]($item.Target | Select-Object -First 1)
}

function Backup-Path([string] $Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return }
  New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
  $name = ($Path -replace '[:\\/]+', '_').Trim('_')
  Copy-Item -LiteralPath $Path -Destination (Join-Path $BackupRoot $name) -Recurse -Force
  $script:BackedUp = $true
}

function Remove-LinkOnly([string] $Path) {
  # Removes a junction/symlink itself; never touches the target's contents.
  & cmd.exe /c rmdir "$Path" | Out-Null
  if (Test-Path -LiteralPath $Path) { throw "Could not remove link: $Path" }
}

function Remove-PathSafely([string] $Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return }
  if (Test-Link $Path) {
    $target = Get-LinkTarget $Path
    Remove-LinkOnly $Path
    Add-Report "removed link  $Path -> $target"
  } else {
    Backup-Path $Path
    Remove-Item -LiteralPath $Path -Recurse -Force
    Add-Report "removed       $Path (backed up)"
  }
}

function Read-Text([string] $Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  return [IO.File]::ReadAllText($Path)
}

function Write-Text([string] $Path, [string] $Text) {
  $dir = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Assert-Markers([string] $Path) {
  # Refuse to edit when the markers are not exactly zero or one well-ordered pair,
  # so a broken block can never swallow the user's own text.
  $text = Read-Text $Path
  if ($null -eq $text) { return }
  $starts = [regex]::Matches($text, [regex]::Escape($StartMarker)).Count
  $ends = [regex]::Matches($text, [regex]::Escape($EndMarker)).Count
  if ($starts -eq 0 -and $ends -eq 0) { return }
  if ($starts -eq 1 -and $ends -eq 1 -and $text.IndexOf($StartMarker) -lt $text.IndexOf($EndMarker)) { return }
  throw "Harness markers in $Path are broken ($starts start, $ends end). Fix them by hand, then run again."
}

function Remove-Block([string] $Path) {
  Assert-Markers $Path
  $text = Read-Text $Path
  if ($null -eq $text -or -not $text.Contains($StartMarker)) { return }
  Backup-Path $Path
  $rest = [regex]::Replace($text, $BlockPattern, "`n")
  if ($rest.Trim().Length -eq 0) {
    Remove-Item -LiteralPath $Path -Force
    Add-Report "removed       $Path (only the harness block was left; backed up)"
  } else {
    Write-Text $Path ($rest.TrimEnd() + "`n")
    Add-Report "removed block $Path (backed up)"
  }
}

function Set-Block([string] $Path, [string] $Body) {
  Assert-Markers $Path
  $block = $StartMarker + "`n" + $Body + "`n" + $EndMarker
  $text = Read-Text $Path
  if ($null -eq $text) {
    Write-Text $Path ($block + "`n")
    Add-Report "created       $Path with harness block"
    return
  }
  $match = [regex]::Match($text, $BlockPattern)
  if ($match.Success -and $match.Value.Trim() -eq $block) {
    Add-Report "unchanged     $Path harness block"
    return
  }
  Backup-Path $Path
  $rest = [regex]::Replace($text, $BlockPattern, "`n").TrimEnd()
  if ($rest.Length -gt 0) { $rest = $rest + "`n`n" }
  Write-Text $Path ($rest + $block + "`n")
  Add-Report "updated       $Path harness block (backed up)"
}

function Get-HarnessSkills {
  $root = Join-Path $HarnessRoot 'skills'
  if (-not (Test-Path -LiteralPath $root)) { return @() }
  return @(Get-ChildItem -LiteralPath $root -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
  })
}

function Invoke-Quiet([string] $CommandLine) {
  # Runs a command through cmd so native stderr does not break PowerShell 5.1.
  $output = & cmd.exe /c "$CommandLine 2>&1"
  return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String) }
}

if ($Uninstall) {
  foreach ($skill in Get-HarnessSkills) {
    $dest = Join-Path $ClaudeSkills $skill.Name
    if ((Test-Link $dest) -and ((Get-LinkTarget $dest) -eq $skill.FullName)) {
      Remove-LinkOnly $dest
      Add-Report "removed link  $dest"
    }
  }
  Remove-Block $ClaudeMd
} else {
  # 1. Old v0 personal harness. Its install root is the signal: old skill folders are
  #    removed only while it still exists, so a later skill that happens to share an
  #    old name is never touched by a re-run.
  if (Test-Path -LiteralPath $OldInstallRoot) {
    foreach ($root in @($AgentsSkills, $ClaudeSkills)) {
      foreach ($name in $OldSkillNames) { Remove-PathSafely (Join-Path $root $name) }
    }
    Remove-PathSafely $OldInstallRoot
  }
  Remove-Block $CodexAgentsMd
  $settingsText = Read-Text $ClaudeSettings
  if ($null -ne $settingsText -and $settingsText.Contains('personal-entry-hook.ps1')) {
    Add-Report "NOTICE        $ClaudeSettings still has an old personal-entry-hook.ps1 hook. Remove it manually."
  }

  # 2. Skills as junctions
  if (-not (Test-Path -LiteralPath $ClaudeSkills)) { New-Item -ItemType Directory -Force -Path $ClaudeSkills | Out-Null }
  foreach ($skill in Get-HarnessSkills) {
    $dest = Join-Path $ClaudeSkills $skill.Name
    if ((Test-Link $dest) -and ((Get-LinkTarget $dest) -eq $skill.FullName)) {
      Add-Report "unchanged     $dest -> $($skill.FullName)"
      continue
    }
    Remove-PathSafely $dest
    New-Item -ItemType Junction -Path $dest -Target $skill.FullName | Out-Null
    Add-Report "linked        $dest -> $($skill.FullName)"
  }

  # 3. Entry import block in ~/.claude/CLAUDE.md
  $entry = (Join-Path $HarnessRoot 'entry.md') -replace '\\', '/'
  Set-Block $ClaudeMd ("@" + $entry)

  # 4. Readiness
  if (Get-Command codex -ErrorAction SilentlyContinue) {
    $version = Invoke-Quiet 'codex --version'
    $login = Invoke-Quiet 'codex login status'
    Add-Report ("check         codex: " + $version.Output.Trim() + " / login: " + ($login.Output.Trim() -split "`r?`n" | Select-Object -First 1))
  } else {
    Add-Report "MISSING       codex CLI is not on PATH"
  }
  if (Get-Command orca -ErrorAction SilentlyContinue) {
    $status = Invoke-Quiet 'orca status --json'
    if ($status.Output -match '"ok"\s*:\s*true') {
      $runs = Invoke-Quiet 'orca orchestration run-list --json'
      if ($runs.Output -match '"ok"\s*:\s*true') {
        Add-Report "check         orca: runtime ready, orchestration available"
      } else {
        Add-Report "CHECK         orca: runtime ready, but orchestration did not answer. Enable it in Settings > Experimental."
      }
    } else {
      Add-Report "CHECK         orca: runtime not reachable. Open Orca and run this script again to re-check."
    }
  } else {
    Add-Report "MISSING       orca CLI is not on PATH (needed only for delegating implementation)"
  }
}

Write-Output "personal harness: $HarnessRoot"
foreach ($line in $Report) { Write-Output "  $line" }
if ($script:BackedUp) { Write-Output "  backup: $BackupRoot" }
