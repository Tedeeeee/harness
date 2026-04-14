Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib.ps1")

$inputJson = Read-HookInput
$summary = Get-ImplementationSummary
$memory = Get-MemorySummary

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

$memoryLine = if ($memory.CombinedText) {
    "Read memory before deciding the next action:`n$($memory.CombinedText)`n"
}
else {
    ""
}

$context = if ($isBlocked) {
    $blockerText = if ($summary.Blockers) { $summary.Blockers } else { "A blocker is recorded in implementation state." }
    "This repository uses self-harness. ${memoryLine}The harness is currently blocked. Do not continue planning or execution yet. Read docs state first, then ask the user exactly one concise question needed to unblock the work. Blocker context: $blockerText"
}
else {
    "This repository uses self-harness. ${memoryLine}Before responding to the prompt, read docs state and route from prompt plus state, not prompt alone. $stateLine If planning is incomplete, do not jump directly to implementation."
}

Write-AdditionalContextJson -HookEventName "UserPromptSubmit" -AdditionalContext $context
