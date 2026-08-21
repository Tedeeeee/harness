$ErrorActionPreference = 'Stop'

$HarnessRoot = Split-Path -Parent $PSScriptRoot
$ExpectedSkills = @(
  'feature-orchestrator',
  'requirements-impact',
  'architecture-design',
  'implementation',
  'verification-review'
)

function Assert-True([bool] $Condition, [string] $Message) {
  if (-not $Condition) {
    throw "FAIL: $Message"
  }
}

Assert-True (Test-Path (Join-Path $HarnessRoot 'README.md')) 'README.md must exist.'
Assert-True (Test-Path (Join-Path $HarnessRoot 'AGENTS.md')) 'AGENTS.md must exist.'
Assert-True (Test-Path (Join-Path $HarnessRoot 'CLAUDE.md')) 'CLAUDE.md must exist.'

foreach ($skill in $ExpectedSkills) {
  $source = Join-Path $HarnessRoot "skills-src\$skill\SKILL.md"
  $codex = Join-Path $HarnessRoot ".agents\skills\$skill\SKILL.md"
  $claude = Join-Path $HarnessRoot ".claude\skills\$skill\SKILL.md"

  Assert-True (Test-Path $source) "Missing source skill: $skill"
  Assert-True (Test-Path $codex) "Missing Codex skill mirror: $skill"
  Assert-True (Test-Path $claude) "Missing Claude skill mirror: $skill"

  $sourceText = Get-Content -Raw $source
  Assert-True (($sourceText -eq (Get-Content -Raw $codex))) "Codex mirror differs: $skill"
  Assert-True (($sourceText -eq (Get-Content -Raw $claude))) "Claude mirror differs: $skill"
  Assert-True ($sourceText -match '(?ms)^---\s*\nname:\s*[a-z0-9-]+\s*\ndescription:\s*Use when .+?\n---') "Invalid frontmatter: $skill"
}

Write-Output 'PASS: harness contract'

