Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib.ps1")

$null = Read-HookInput
$summary = Get-ImplementationSummary

$isDone = $summary.CurrentStatus -eq "done" -or $summary.CurrentStep -eq "completed"
$isBlocked = $false
if ($summary.CurrentStatus -and $summary.CurrentStatus.ToLowerInvariant() -match "blocked") {
    $isBlocked = $true
}
elseif ($summary.Blockers -and $summary.Blockers.Trim().ToLowerInvariant() -ne "none") {
    $isBlocked = $true
}

$context = if (-not $summary.Exists) {
    "self-harness project detected. No implementation state exists yet. Route from prompt plus docs state. Start by checking docs/requirements and use route-self-harness before choosing a planning or execution skill."
}
elseif ($isBlocked) {
    $blockerText = if ($summary.Blockers) { $summary.Blockers } else { "A blocker is recorded in implementation state." }
    "self-harness project detected. The harness is currently blocked. Do not continue planning or execution yet. Your next response must ask the user exactly one concise question needed to unblock the work. Blocker context: $blockerText"
}
elseif ($isDone) {
    "self-harness project detected. The last recorded implementation state is complete. If the user wants new work, begin by routing from the current prompt and docs state instead of assuming implementation should continue."
}
else {
    $nextAction = if ($summary.NextAllowedAction) { $summary.NextAllowedAction } else { "Check docs/implementation/implementation-state.md for the next allowed action." }
    "self-harness project detected. Recover state from docs before acting. Current step: $($summary.CurrentStep). Current status: $($summary.CurrentStatus). Next allowed action: $nextAction Route through route-self-harness before continuing."
}

Write-AdditionalContextJson -HookEventName "SessionStart" -AdditionalContext $context
