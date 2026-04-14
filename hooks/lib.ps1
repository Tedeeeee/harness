Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-HookInput {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    return $raw | ConvertFrom-Json
}

function Get-ProjectPath {
    if ($env:CLAUDE_PROJECT_DIR -and (Test-Path -LiteralPath $env:CLAUDE_PROJECT_DIR)) {
        return $env:CLAUDE_PROJECT_DIR
    }

    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Get-ImplementationStatePath {
    $projectRoot = Get-ProjectPath
    return Join-Path $projectRoot "docs\\implementation\\implementation-state.md"
}

function Get-ImplementationStateText {
    $path = Get-ImplementationStatePath
    if (-not (Test-Path -LiteralPath $path)) {
        return $null
    }

    return Get-Content -LiteralPath $path -Raw
}

function Get-ImplementationSummary {
    $text = Get-ImplementationStateText
    if (-not $text) {
        return [pscustomobject]@{
            Exists = $false
            CurrentStep = $null
            CurrentStatus = $null
            NextAllowedAction = $null
            Blockers = $null
            PendingSteps = @()
            ActiveSteps = @()
        }
    }

    $currentStep = $null
    $currentStatus = $null
    $nextAllowedAction = $null
    $blockers = $null

    if ($text -match '(?m)^- Current Step:\s*(.+)$') {
        $currentStep = $matches[1].Trim()
    }

    if ($text -match '(?m)^- Current Status:\s*(.+)$') {
        $currentStatus = $matches[1].Trim()
    }

    if ($text -match '(?ms)^## Next Allowed Action\s*-+\s*(.+?)(?:\r?\n## |\z)') {
        $nextAllowedAction = ($matches[1] -replace '\r', '').Trim()
    }

    if ($text -match '(?ms)^## Blockers\s*-+\s*(.+?)(?:\r?\n## |\z)') {
        $blockers = ($matches[1] -replace '\r', '').Trim()
    }

    $pendingSteps = @()
    $activeSteps = @()
    foreach ($line in ($text -split "`r?`n")) {
        if ($line -match '^\|\s*(step-\d+)\s*\|\s*[^|]+\|\s*pending\s*\|') {
            $pendingSteps += $matches[1]
        }
        elseif ($line -match '^\|\s*(step-\d+)\s*\|\s*[^|]+\|\s*in_progress\s*\|') {
            $activeSteps += $matches[1]
        }
    }

    return [pscustomobject]@{
        Exists = $true
        CurrentStep = $currentStep
        CurrentStatus = $currentStatus
        NextAllowedAction = $nextAllowedAction
        Blockers = $blockers
        PendingSteps = $pendingSteps
        ActiveSteps = $activeSteps
    }
}

function Write-AdditionalContextJson {
    param(
        [Parameter(Mandatory = $true)][string]$HookEventName,
        [Parameter(Mandatory = $true)][string]$AdditionalContext
    )

    @{
        hookSpecificOutput = @{
            hookEventName = $HookEventName
            additionalContext = $AdditionalContext
        }
    } | ConvertTo-Json -Depth 10 -Compress
}

function Write-BlockDecisionJson {
    param(
        [Parameter(Mandatory = $true)][string]$Reason
    )

    @{
        decision = "block"
        reason = $Reason
    } | ConvertTo-Json -Depth 10 -Compress
}
