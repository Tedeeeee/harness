Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib.ps1")

$inputJson = Read-HookInput
$summary = Get-ImplementationSummary

$prompt = ""
if ($inputJson -and $inputJson.PSObject.Properties.Name -contains "prompt") {
    $prompt = [string]$inputJson.prompt
}

$stateLine = if (-not $summary.Exists) {
    "No implementation state file exists yet."
}
else {
    "Current step: $($summary.CurrentStep). Current status: $($summary.CurrentStatus)."
}

$isBlocked = $false
if ($summary.Exists) {
    if ($summary.CurrentStatus -and $summary.CurrentStatus.ToLowerInvariant() -match "blocked") {
        $isBlocked = $true
    }
    elseif ($summary.Blockers -and $summary.Blockers.Trim().ToLowerInvariant() -ne "none") {
        $isBlocked = $true
    }
}

$context = if ($isBlocked) {
    $blockerText = if ($summary.Blockers) { $summary.Blockers } else { "A blocker is recorded in implementation state." }
    "This repository uses self-harness. The harness is currently blocked. Do not continue planning or execution yet. Read docs state first, then ask the user exactly one concise question needed to unblock the work. Blocker context: $blockerText Prompt received: $prompt"
}
else {
    "This repository uses self-harness. Before responding to the prompt, read docs state and route from prompt plus state, not prompt alone. $stateLine If planning is incomplete, do not jump directly to implementation. Prompt received: $prompt"
}

Write-AdditionalContextJson -HookEventName "UserPromptSubmit" -AdditionalContext $context
