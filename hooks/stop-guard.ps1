Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib.ps1")

$null = Read-HookInput
$summary = Get-ImplementationSummary

if (-not $summary.Exists) {
    exit 0
}

$status = if ($summary.CurrentStatus) { $summary.CurrentStatus.ToLowerInvariant() } else { "" }
$blockers = if ($summary.Blockers) { $summary.Blockers.ToLowerInvariant() } else { "" }
$nextAction = if ($summary.NextAllowedAction) { $summary.NextAllowedAction.ToLowerInvariant() } else { "" }
$currentStep = if ($summary.CurrentStep) { $summary.CurrentStep.ToLowerInvariant() } else { "" }

if ($status -match "verification-ready" -or $nextAction -match "verify-current-step|verification") {
    Write-BlockDecisionJson -Reason "Current step is ready for verification. Run verify-current-step before stopping."
    exit 0
}

if (($status -match "blocked") -or ($blockers -and $blockers -ne "none")) {
    Write-BlockDecisionJson -Reason "Blocked work is recorded in implementation state. Do not stop. Ask the user exactly one concise question needed to unblock the work, then continue through implementation-blocker or planner logic."
    exit 0
}

$allDone = ($status -eq "done") -or ($currentStep -eq "completed") -or (($summary.PendingSteps.Count -eq 0) -and ($summary.ActiveSteps.Count -eq 0) -and $nextAction -match "none")
if ($allDone) {
    exit 0
}

if (($summary.PendingSteps.Count -gt 0) -and ($summary.ActiveSteps.Count -eq 0)) {
    $nextStep = $summary.PendingSteps[0]
    Write-BlockDecisionJson -Reason "A pending step remains with no active step. Run implementation-start to activate $nextStep before stopping."
    exit 0
}

if (($status -match "in_progress") -and $nextAction) {
    Write-BlockDecisionJson -Reason "Implementation is still in progress. Continue the active step or move it to verification-ready before stopping."
    exit 0
}

exit 0
