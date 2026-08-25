$ErrorActionPreference = 'Stop'

$HarnessRoot = Split-Path -Parent $PSScriptRoot
$ExpectedSkills = @(
  'personal-orchestration',
  'feature-orchestration',
  'requirements-analysis',
  'architecture-design',
  'implementation',
  'verification-and-review',
  'branch-integration'
)

function Assert-True([bool] $Condition, [string] $Message) {
  if (-not $Condition) {
    throw "FAIL: $Message"
  }
}

function Read-Json([string] $RelativePath) {
  $path = Join-Path $HarnessRoot $RelativePath
  Assert-True (Test-Path -LiteralPath $path) "Missing JSON file: $RelativePath"
  try {
    return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
  } catch {
    throw "FAIL: Invalid JSON: $RelativePath - $($_.Exception.Message)"
  }
}

Assert-True (Test-Path (Join-Path $HarnessRoot 'README.md')) 'README.md must exist.'
Assert-True (Test-Path (Join-Path $HarnessRoot 'AGENTS.md')) 'AGENTS.md must exist.'
Assert-True (Test-Path (Join-Path $HarnessRoot 'CLAUDE.md')) 'CLAUDE.md must exist.'
Assert-True (Test-Path (Join-Path $HarnessRoot 'rules\project-feature-documentation.md')) 'Project documentation rule must exist.'
Assert-True (Test-Path (Join-Path $HarnessRoot 'templates\feature-document.md')) 'Feature document template must exist.'
Assert-True (Test-Path (Join-Path $HarnessRoot 'adapters\orca\README.md')) 'Orca adapter documentation must exist.'
foreach ($scriptName in @('attach-project.ps1', 'sync-project-overlay.ps1', 'sync-global-harness.ps1', 'personal-entry-hook.ps1', 'verify-worktree.ps1', 'ensure-codex-speed-policy.ps1', 'start-feature-run.ps1', 'route-agent.ps1', 'validate-json-contracts.ps1', 'validate-feature-transition.ps1', 'verify-feature-document.ps1')) {
  Assert-True (Test-Path (Join-Path $HarnessRoot "scripts\$scriptName")) "Missing harness script: $scriptName"
}

$featureWorkflow = Read-Json 'core\workflows\feature-run.json'
$integrationWorkflow = Read-Json 'core\workflows\integration-run.json'
$routing = Read-Json 'core\agent-routing.json'
$handoff = Read-Json 'core\contracts\handoff.schema.json'
$conflict = Read-Json 'core\contracts\conflict-report.schema.json'
$receipt = Read-Json 'core\contracts\merge-receipt.schema.json'

Assert-True ((($featureWorkflow.phases | ForEach-Object { $_.id }) -join ',') -eq 'requirements-analysis,architecture-design,implementation,verification-and-review,branch-integration') 'Feature phase order is invalid.'
Assert-True ($featureWorkflow.inputPolicy.requiredFromUser -contains 'intent') 'Feature Run must require only user intent.'
Assert-True ($featureWorkflow.inputPolicy.phaseInstructionsOptional -eq $true) 'Phase instructions must be optional for users.'
Assert-True ($featureWorkflow.inputPolicy.modelSelectionUserOwned -eq $false) 'Model selection must remain an orchestration concern.'
Assert-True ($featureWorkflow.inputPolicy.userProposedSolutionIsHypothesis -eq $true) 'User solutions must be verified as hypotheses.'
Assert-True ($featureWorkflow.entrypoint.owner -eq 'harness-bootstrap') 'Feature Run must have a Harness bootstrap entrypoint.'
Assert-True ($featureWorkflow.entrypoint.createsOneDerivedWorktree -eq $true) 'Bootstrap must create one derived worktree per Feature Run.'
Assert-True ($featureWorkflow.entrypoint.createsOrcaRun -eq $true) 'Bootstrap must create the Orca Run.'
Assert-True ($featureWorkflow.entrypoint.coordinatorPhase -eq 'feature-orchestration') 'Bootstrap must start the Coordinator phase.'
Assert-True ($featureWorkflow.entrypoint.mustRunBeforeProjectInspection -eq $true) 'Bootstrap must run before project inspection.'
Assert-True ($featureWorkflow.entrypoint.trigger -eq 'first-behavior-changing-request-in-any-session') 'Any supported session must trigger bootstrap on the first behavior-changing request.'
Assert-True ($featureWorkflow.entrypoint.automaticFromDirectSession -eq $true) 'Direct Claude or Codex sessions must bootstrap automatically.'
Assert-True ($featureWorkflow.entrypoint.userRunsBootstrap -eq $false) 'The user must not be required to run the bootstrap script manually.'
Assert-True ($featureWorkflow.entrypoint.dirtyBasePolicy -eq 'fork-from-base-head-and-preserve') 'A dirty base worktree must fork from the base HEAD and preserve uncommitted changes in the base.'
Assert-True ($featureWorkflow.entrypoint.normalWorkflowUsesPreview -eq $false) 'Normal workflow must use live bootstrap, not Preview.'
Assert-True ($featureWorkflow.coordinator.route -eq 'coordinator') 'Feature Run must define a Coordinator route.'
Assert-True ($featureWorkflow.coordinator.userFacing -eq $true) 'Coordinator must own user communication.'
Assert-True ($featureWorkflow.coordinator.singleSession -eq $true) 'A Feature Run must use one feature-agent session by default.'
Assert-True ($featureWorkflow.coordinator.createsChildTasks -eq $false) 'A Feature Run must not create child Tasks by default.'
Assert-True ($featureWorkflow.userConversation.owner -eq 'feature-agent') 'The Feature Agent must own the user conversation.'
Assert-True ($featureWorkflow.userConversation.transport -eq 'feature-agent-chat') 'User communication must use the Feature Agent chat.'
Assert-True ($featureWorkflow.userConversation.userGateTransport -eq 'feature-agent-chat') 'User gates must use the Feature Agent chat.'
Assert-True ($featureWorkflow.userConversation.orcaAskForUserGate -eq $false) 'Orca ask must not be used as the user gate transport.'
Assert-True ($featureWorkflow.userConversation.internalMessagesVisible -eq $false) 'Internal Orca messages must not be presented as user conversation.'
Assert-True ($featureWorkflow.userConversation.mustExplainBeforeQuestion -eq $true) 'A user gate must explain findings before asking a question.'
Assert-True ($featureWorkflow.userConversation.waitsForUserReplyInSameSession -eq $true) 'A user gate must wait for the user in the same Feature Agent session.'
Assert-True ($featureWorkflow.intake.owner -eq 'feature-orchestration') 'Intake must belong to the feature orchestrator.'
Assert-True ($featureWorkflow.intake.workerPhase -eq $false) 'Intake must not create another specialist phase.'
Assert-True ($featureWorkflow.intake.featureRunWhen -contains 'schema-or-migration-change') 'Schema changes must enter a Feature Run.'
Assert-True ($featureWorkflow.executionPolicy.requiresBoundOrcaRun -eq $true) 'Every Feature Run must require a bound Orca Run.'
Assert-True ($featureWorkflow.executionPolicy.requiresTaskForWorkerDispatch -eq $false) 'Single-session phases must not require child worker dispatches.'
Assert-True ($featureWorkflow.executionPolicy.implementationRequiresExplicitDesignApproval -eq $true) 'Implementation must require explicit design approval.'
Assert-True ($featureWorkflow.executionPolicy.genericContinuationIsNotApproval -eq $true) 'Generic continuation must not be treated as implementation approval.'
Assert-True ($featureWorkflow.executionPolicy.progressReporting.required -eq $true) 'Progress reporting must be required.'
Assert-True ($featureWorkflow.executionPolicy.progressReporting.events -contains 'gate_waiting') 'Gate waiting must be a progress event.'
Assert-True ($featureWorkflow.executionPolicy.progressReporting.events -contains 'phase_started') 'Phase start must be a progress event.'
Assert-True ($featureWorkflow.executionPolicy.childTaskDefault -eq 'disabled') 'Child Task delegation must be disabled by default.'
Assert-True ($featureWorkflow.executionPolicy.userGateOwner -eq 'feature-agent') 'The feature agent must own user gates directly.'
Assert-True ($featureWorkflow.phases[2].workerRequired -eq $false) 'Implementation must run in the feature-agent session.'
Assert-True ($featureWorkflow.phases[2].requiredApproval -eq 'user-approved') 'Implementation must require the user-approved state.'
Assert-True ($featureWorkflow.phases[2].approval.type -eq 'explicit-design-approval') 'Implementation approval must be tied to the approved design.'
Assert-True ((($integrationWorkflow.phases | ForEach-Object { $_.id }) -join ',') -eq 'merge-preview,conflict-resolution,verification,merge-approval') 'Integration phase order is invalid.'
Assert-True ($routing.routes.'requirements-analysis'.model -eq 'gpt-5.6-sol') 'Requirements route must use Sol.'
Assert-True ($routing.routes.'requirements-analysis'.effort -eq 'high') 'Requirements route must use high effort.'
Assert-True ($routing.routes.coordinator.model -eq 'claude-opus-5') 'Coordinator route must use Opus 5.'
Assert-True ($null -eq $routing.routes.coordinator.effort) 'The Opus route must leave effort to the provider default.'
Assert-True ($routing.routes.coordinator.provider -eq 'claude') 'The default feature agent must use Claude.'
Assert-True ($routing.routes.coordinator.model -eq 'claude-opus-5') 'The default feature agent must use Opus 5.'
Assert-True ($routing.fallbackPolicy.provider -eq 'codex') 'Provider fallback must use Codex.'
Assert-True ($routing.fallbackPolicy.trigger -eq 'quota-or-provider-unavailable') 'Fallback must require an actual provider limit or availability failure.'
Assert-True ($routing.routes.'implementation'.model -eq 'claude-opus-5') 'Implementation route must use Opus 5.'
Assert-True ($routing.routes.'verification-and-review'.model -eq 'gpt-5.6-luna') 'Verification route must use Luna.'
Assert-True ($routing.routes.'verification-and-review'.effort -eq 'xhigh') 'Verification route must use xhigh effort.'
Assert-True ($routing.fastPolicy.defaultEnabled -eq $false) 'Fast mode must be disabled by default.'
Assert-True ($routing.fastPolicy.explicitPromptOptIn -eq $true) 'Fast mode must require explicit prompt opt-in.'
Assert-True ($routing.fastPolicy.marker -eq 'fast') 'Fast mode must use the documented prompt marker.'
Assert-True ($routing.fastPolicy.scope -eq 'feature-run') 'Fast mode must be fixed at Feature Run intake.'
Assert-True ($routing.fastPolicy.defaultServiceTier -eq 'default') 'Fast policy must use the default service tier unless opted in.'
Assert-True ($routing.fastPolicy.fastServiceTier -eq 'priority') 'Fast policy must map to the priority service tier.'
Assert-True ($routing.fastPolicy.toggleCommand -eq '/fast') 'Fast policy must use the runtime toggle command.'
Assert-True ($handoff.required -contains 'phase') 'Handoff contract must identify the phase.'
Assert-True ($conflict.required -contains 'files') 'Conflict contract must contain files.'
Assert-True ($receipt.required -contains 'verified') 'Merge receipt must contain verification evidence.'

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

$featureSkillText = Get-Content -Raw (Join-Path $HarnessRoot 'skills-src\feature-orchestration\SKILL.md')
$personalSkillText = Get-Content -Raw (Join-Path $HarnessRoot 'skills-src\personal-orchestration\SKILL.md')
Assert-True ($personalSkillText -match 'first behavior-changing request') 'Personal orchestration must bootstrap on the first behavior-changing request.'
Assert-True ($personalSkillText -match '(?i)optional|optional overlay') 'Personal orchestration must be optional.'
Assert-True ($personalSkillText -match '(?i)config\.json') 'Personal orchestration must require an activation config.'
Assert-True ($personalSkillText -match '(?i)follow.*project|project.*rules') 'Personal orchestration must fall back to project rules when inactive.'
Assert-True ($personalSkillText -match 'Do not ask the user to run') 'Personal orchestration must not delegate bootstrap to the user.'
Assert-True ($personalSkillText -match 'one feature Worktree and one Coordinator') 'Personal orchestration must preserve the single Coordinator boundary.'
Assert-True ($personalSkillText -match 'dirty.*base.*HEAD|HEAD.*dirty.*base') 'Personal orchestration must fork from base HEAD when the base worktree is dirty.'
Assert-True ($personalSkillText -match 'Do not create child') 'Personal orchestration must not create child agents for ordinary phases.'
Assert-True ($featureSkillText -match '## Bootstrap') 'Feature orchestration must define its bootstrap.'
Assert-True ($featureSkillText -match 'external global installation') 'Feature orchestration must support the external global installation.'
Assert-True ($featureSkillText -match 'PERSONAL_HARNESS_ROOT') 'Feature orchestration must support an external Harness Core root.'
Assert-True ($featureSkillText -match '## Coordinator conversation') 'Feature orchestration must define the Coordinator conversation.'
Assert-True ($featureSkillText -match '## Phase order') 'Feature orchestration must define the phase order.'
Assert-True ($featureSkillText -match 'Continue.*does not approve implementation') 'Feature orchestration must distinguish continuation from approval.'
Assert-True ($featureSkillText -match 'read-only') 'Requirements and design phases must be explicitly read-only.'
Assert-True ($featureSkillText -match 'Coordinator') 'Feature orchestration must define the Coordinator role.'
Assert-True ($featureSkillText -match 'one user conversation') 'Coordinator must own the user conversation.'
Assert-True ($featureSkillText -match 'Do not create child') 'Feature orchestration must prohibit default child Agent creation.'
Assert-True ($featureSkillText -match 'Skill routing|skill routing') 'Feature orchestration must define phase Skill routing.'
Assert-True ($featureSkillText -match 'dirty.*base.*HEAD|HEAD.*dirty.*base') 'Feature orchestration must fork from base HEAD when the base worktree is dirty.'
Assert-True ($featureSkillText -match 'Preview.*harness tests') 'Preview must be restricted to harness tests.'
Assert-True ($featureSkillText -match 'standalone prompt marker `fast`') 'Fast must require the explicit prompt marker.'
Assert-True ($featureSkillText -match 'global prompt hook') 'Feature orchestration must explicitly avoid global prompt hooks.'

$gateRuleText = Get-Content -Raw (Join-Path $HarnessRoot 'rules\interaction-gates.md')
Assert-True ($gateRuleText -match 'Confirm.*requirements') 'Gate rules must define what Confirm permits.'
Assert-True ($gateRuleText -match 'Approve.*implementation') 'Gate rules must define what Approve permits.'
Assert-True ($gateRuleText -match 'continue.*not.*approval') 'Gate rules must reject generic continuation as approval.'

$orcaAdapterText = Get-Content -Raw (Join-Path $HarnessRoot 'adapters\orca\README.md')
Assert-True ($orcaAdapterText -match 'Run.*Feature Agent') 'Orca adapter must require a Run before the Feature Agent.'
Assert-True ($orcaAdapterText -match 'Feature Task') 'Orca adapter must require a Feature Task.'
Assert-True ($orcaAdapterText -match 'progress') 'Orca adapter must define progress reporting.'
Assert-True ($orcaAdapterText -match 'Coordinator') 'Orca adapter must define the Coordinator worker.'
Assert-True ($orcaAdapterText -match 'one.*Worktree') 'Orca adapter must preserve one Worktree per Feature Run.'
Assert-True ($orcaAdapterText -match 'must not carry a user gate') 'Orca adapter must prohibit ask/reply for user gates.'
Assert-True ($orcaAdapterText -match 'native.*chat|Feature Agent chat') 'Orca adapter must define the direct Feature Agent chat.'

$overlayScriptText = Get-Content -Raw (Join-Path $HarnessRoot 'scripts\sync-project-overlay.ps1')
Assert-True ($overlayScriptText -notmatch 'Personal Orchestration Harness') 'Project overlay must not install the personal entry bridge.'
Assert-True ($overlayScriptText -notmatch "'personal-orchestration'") 'Project overlay must not install the personal orchestration skill.'

foreach ($staleSkill in @('feature-orchestrator', 'requirements-impact', 'verification-review')) {
  Assert-True (-not (Test-Path (Join-Path $HarnessRoot "skills-src\$staleSkill\SKILL.md"))) "Stale source skill remains: $staleSkill"
  Assert-True (-not (Test-Path (Join-Path $HarnessRoot ".agents\skills\$staleSkill\SKILL.md"))) "Stale Codex mirror remains: $staleSkill"
  Assert-True (-not (Test-Path (Join-Path $HarnessRoot ".claude\skills\$staleSkill\SKILL.md"))) "Stale Claude mirror remains: $staleSkill"
}

$routeScript = Join-Path $HarnessRoot 'scripts\route-agent.ps1'
$planningRoute = (& $routeScript -Phase requirements-analysis | ConvertFrom-Json)
$lowRiskPlanningRoute = (& $routeScript -Phase requirements-analysis -Risk low | ConvertFrom-Json)
$highRiskPlanningRoute = (& $routeScript -Phase architecture-design -Risk high | ConvertFrom-Json)
$verificationRoute = (& $routeScript -Phase verification-and-review | ConvertFrom-Json)
$coordinatorRoute = (& $routeScript -Phase coordinator | ConvertFrom-Json)
$fastCoordinatorRoute = (& $routeScript -Phase coordinator -Fast | ConvertFrom-Json)
Assert-True ($planningRoute.model -eq 'gpt-5.6-sol') 'Route command returned the wrong planning model.'
Assert-True ($planningRoute.effort -eq 'high') 'Route command returned the wrong planning effort.'
Assert-True ($lowRiskPlanningRoute.effort -eq 'medium') 'Low-risk planning must use medium effort.'
Assert-True ($highRiskPlanningRoute.effort -eq 'xhigh') 'High-risk design must use xhigh effort.'
Assert-True ($verificationRoute.model -eq 'gpt-5.6-luna') 'Route command returned the wrong verification model.'
Assert-True ($coordinatorRoute.model -eq 'claude-opus-5') 'Route command returned the wrong feature-agent model.'
Assert-True ($null -eq $coordinatorRoute.effort) 'Route command must leave Opus effort to the provider default.'
Assert-True ($coordinatorRoute.fastRequested -eq $false) 'Normal routes must not request Fast mode.'
Assert-True ($fastCoordinatorRoute.fastRequested -eq $true) 'Explicit Fast routes must report the request.'
Assert-True ($null -eq $fastCoordinatorRoute.effort) 'Fast must not invent a reasoning effort for Opus.'
Assert-True ($fastCoordinatorRoute.fastCommand -eq '/fast') 'Explicit Fast routes must expose the runtime toggle command.'

$startScript = Join-Path $HarnessRoot 'scripts\start-feature-run.ps1'
 $startScriptText = Get-Content -Raw $startScript
Assert-True ($startScriptText -notmatch 'agent_prompt_stalled') 'Feature bootstrap must not contain stalled-agent auto-recovery.'
Assert-True ($startScriptText -notmatch 'retry-of') 'Feature bootstrap must not retry a failed worker automatically.'
$speedPolicyScript = Join-Path $HarnessRoot 'scripts\ensure-codex-speed-policy.ps1'
$speedFixture = Join-Path ([System.IO.Path]::GetTempPath()) "harness-speed-$([guid]::NewGuid().ToString('N')).toml"
try {
  $speedFixtureText = 'service_tier = "priority"' + [Environment]::NewLine + '[desktop]' + [Environment]::NewLine + 'default-service-tier = "priority"' + [Environment]::NewLine
  Set-Content -LiteralPath $speedFixture -Value $speedFixtureText -Encoding utf8
  $speedResult = (& $speedPolicyScript -ConfigPath $speedFixture | ConvertFrom-Json)
  Assert-True ($speedResult.serviceTier -eq 'default') 'Speed policy must enforce the default service tier.'
  Assert-True ($speedResult.changed -eq $true) 'Speed policy must repair a priority default.'
  Assert-True ((Get-Content -Raw -LiteralPath $speedFixture) -notmatch 'service_tier\s*=\s*"priority"') 'Speed policy must remove the priority service tier.'
} finally {
  if (Test-Path -LiteralPath $speedFixture) {
    Remove-Item -LiteralPath $speedFixture -Force
  }
}

$startFixture = Join-Path ([System.IO.Path]::GetTempPath()) "harness-start-$([guid]::NewGuid().ToString('N'))"
try {
  New-Item -ItemType Directory -Path $startFixture | Out-Null
  & git -C $startFixture init --quiet
  & git -C $startFixture checkout -b main --quiet
  Set-Content -LiteralPath (Join-Path $startFixture 'AGENTS.md') -Value '# Fixture Agents' -Encoding utf8
  Set-Content -LiteralPath (Join-Path $startFixture 'CLAUDE.md') -Value '# Fixture Claude' -Encoding utf8
  & git -C $startFixture config user.email 'harness-test@example.invalid'
  & git -C $startFixture config user.name 'Harness Test'
  & git -C $startFixture add AGENTS.md CLAUDE.md
  & git -C $startFixture commit --quiet -m 'fixture'
  $startResult = (& $startScript -ProjectPath $startFixture -BaseBranch main -Intent 'Client name integrity needs a fix.' -FeatureTitle 'Client Name Integrity Fix' -Preview | ConvertFrom-Json)
  Assert-True ($startResult.mode -eq 'preview') 'Feature bootstrap preview must not create runtime state.'
  Assert-True ($startResult.featureId -eq 'client-name-integrity-fix') 'Feature bootstrap must derive a stable feature id.'
  Assert-True ($startResult.derivedBranch -eq 'orch/client-name-integrity-fix') 'Feature bootstrap must derive the feature branch.'
  Assert-True ($startResult.coordinatorRoute -eq 'coordinator') 'Feature bootstrap must select the Coordinator route.'
  Assert-True ($startResult.coordinatorProvider -eq 'claude') 'Feature bootstrap must select Claude as the feature agent.'
  Assert-True ($startResult.coordinatorModel -eq 'claude-opus-5') 'Feature bootstrap must select Opus 5 as the feature agent.'
  Assert-True ($startResult.executionMode -eq 'single-session') 'Feature bootstrap must use single-session execution.'
  Assert-True ($startResult.childTaskPolicy -eq 'disabled-by-default') 'Feature bootstrap must disable child Tasks by default.'
  Assert-True ($startResult.userConversationTransport -eq 'feature-agent-chat') 'Feature bootstrap must route user conversation to the Feature Agent chat.'
  Assert-True ($startResult.orcaAskForUserGate -eq $false) 'Feature bootstrap must disable Orca ask for user gates.'
  Assert-True ($startResult.fastRequested -eq $false) 'Normal Feature Runs must not request Fast mode.'
  Assert-True ($startResult.bootstrapMode -eq 'automatic-from-entry-session') 'Feature bootstrap must declare automatic entry-session mode.'
  Assert-True ($startResult.userRunsBootstrap -eq $false) 'Feature bootstrap must not require the user to run the script.'
  Assert-True ($startResult.baseBranchSource -eq 'current-checked-out-branch-head') 'Feature bootstrap must derive the base snapshot from the current branch HEAD.'
  Assert-True ($startResult.dirtyBasePolicy -eq 'fork-from-base-head-and-preserve') 'Feature bootstrap must fork from the base HEAD when the base worktree is dirty.'
  Assert-True ($startResult.baseWorktreeClean -eq $true) 'A clean base preview must report a clean base worktree.'
  Assert-True (-not $startResult.nextStep) 'Feature bootstrap must not delegate Run creation back to the user.'

  Set-Content -LiteralPath (Join-Path $startFixture 'uncommitted.txt') -Value 'dirty' -Encoding utf8
  $dirtyStartResult = (& $startScript -ProjectPath $startFixture -BaseBranch main -Intent 'Dirty base must fork.' -FeatureTitle 'Dirty Base Fork' -Preview | ConvertFrom-Json)
  Assert-True ($dirtyStartResult.mode -eq 'preview') 'A dirty base preview must still return a bootstrap plan.'
  Assert-True ($dirtyStartResult.baseWorktreeClean -eq $false) 'A dirty base preview must report the dirty state.'
  Assert-True ($dirtyStartResult.baseBranchSource -eq 'current-checked-out-branch-head') 'A dirty base must use the checked-out branch HEAD as the child worktree source.'
  Assert-True (-not [string]::IsNullOrWhiteSpace([string]$dirtyStartResult.baseCommit)) 'A dirty base preview must identify the commit used for the child worktree.'
  Remove-Item -LiteralPath (Join-Path $startFixture 'uncommitted.txt') -Force

  $fastStartResult = (& $startScript -ProjectPath $startFixture -BaseBranch main -Intent 'fast Client name integrity needs a fix.' -FeatureTitle 'Client Name Integrity Fast Fix' -Preview | ConvertFrom-Json)
  Assert-True ($fastStartResult.fastRequested -eq $true) 'A standalone fast marker must opt the Feature Run into Fast mode.'
  Assert-True ($null -eq $fastStartResult.coordinatorEffort) 'Fast must not invent a reasoning effort for Opus.'
  Assert-True ($fastStartResult.fastCommand -eq '/fast') 'Fast Feature Runs must expose the runtime toggle command.'
} finally {
  if (Test-Path -LiteralPath $startFixture) {
    Remove-Item -LiteralPath $startFixture -Recurse -Force
  }
}

$transitionScript = Join-Path $HarnessRoot 'scripts\validate-feature-transition.ps1'
$analysisTransition = (& $transitionScript -CurrentState prepared -TargetPhase requirements-analysis -RunId run-test -TaskId task-test | ConvertFrom-Json)
Assert-True ($analysisTransition.allowed -eq $true) 'A prepared Feature Run with Orca Run and Task may enter requirements analysis.'

function Invoke-Transition([string] $State, [string] $Phase, [string] $Decision = 'none', [string] $RunId, [string] $TaskId) {
  $output = @(& $transitionScript -CurrentState $State -TargetPhase $Phase -Decision $Decision -RunId $RunId -TaskId $TaskId 2>&1)
  [pscustomobject]@{
    result = (($output -join "`n") | ConvertFrom-Json)
  }
}

$analysisWithoutTask = Invoke-Transition 'prepared' 'requirements-analysis' 'none' 'run-test' $null
Assert-True ($analysisWithoutTask.result.allowed -eq $false) 'A Feature Run must reject a missing Feature Task.'

$continueIntoImplementation = Invoke-Transition 'user-confirmed' 'implementation' 'continue' 'run-test' 'task-test'
Assert-True ($continueIntoImplementation.result.allowed -eq $false) 'Generic continuation must not enter implementation.'

$implementationWithoutApproval = Invoke-Transition 'user-confirmed' 'implementation' 'none' 'run-test' 'task-test'
Assert-True ($implementationWithoutApproval.result.allowed -eq $false) 'Implementation must reject an unapproved design.'

$implementationWithoutRun = Invoke-Transition 'user-approved' 'implementation' 'none' $null 'task-test'
Assert-True ($implementationWithoutRun.result.allowed -eq $false) 'Implementation must reject a missing Orca Run.'

$architectureSkip = Invoke-Transition 'prepared' 'architecture-design' 'continue' 'run-test' 'task-test'
Assert-True ($architectureSkip.result.allowed -eq $false) 'Architecture design must not skip requirements confirmation.'

$verificationSkip = Invoke-Transition 'user-approved' 'verification-and-review' 'none' 'run-test' 'task-test'
Assert-True ($verificationSkip.result.allowed -eq $false) 'Verification must not skip implementation.'

$approvedImplementation = (& $transitionScript -CurrentState user-approved -TargetPhase implementation -Decision approve -RunId run-test -TaskId task-test | ConvertFrom-Json)
Assert-True ($approvedImplementation.allowed -eq $true) 'Explicitly approved design with Orca Run and Task may enter implementation.'

$documentScript = Join-Path $HarnessRoot 'scripts\verify-feature-document.ps1'
$documentResult = (& $documentScript -ProjectPath (Join-Path $HarnessRoot 'tests\fixtures') -FeatureId valid-feature -FeatureDocumentRoot '.' | ConvertFrom-Json)
Assert-True ($documentResult.currentStateDocument -eq $true) 'Feature document validator must recognize a current-state document.'

$attachScript = Join-Path $HarnessRoot 'scripts\attach-project.ps1'
$attachFixture = Join-Path ([System.IO.Path]::GetTempPath()) "harness-attach-$([guid]::NewGuid().ToString('N'))"
try {
  New-Item -ItemType Directory -Path $attachFixture | Out-Null
  & git -C $attachFixture init --quiet
  & git -C $attachFixture checkout -b main --quiet
  $attachResult = (& $attachScript -ProjectPath $attachFixture | ConvertFrom-Json)
  Assert-True ($attachResult.deploymentMode -eq 'external-global') 'Projects without an overlay must use external-global mode.'
  Assert-True ($attachResult.projectOverlayRequired -eq $false) 'Project overlay must not be required.'
} finally {
  if (Test-Path -LiteralPath $attachFixture) {
    Remove-Item -LiteralPath $attachFixture -Recurse -Force
  }
}

$overlayScript = Join-Path $HarnessRoot 'scripts\sync-project-overlay.ps1'
$fixtureProject = Join-Path ([System.IO.Path]::GetTempPath()) "harness-overlay-$([guid]::NewGuid().ToString('N'))"
try {
  New-Item -ItemType Directory -Path $fixtureProject | Out-Null
  & git -C $fixtureProject init --quiet
  & git -C $fixtureProject checkout -b main --quiet
  Set-Content -LiteralPath (Join-Path $fixtureProject 'AGENTS.md') -Value '# Fixture Agents' -Encoding utf8
  Set-Content -LiteralPath (Join-Path $fixtureProject 'CLAUDE.md') -Value '# Fixture Claude' -Encoding utf8
  & git -C $fixtureProject config user.email 'harness-test@example.invalid'
  & git -C $fixtureProject config user.name 'Harness Test'
  & git -C $fixtureProject add AGENTS.md CLAUDE.md
  & git -C $fixtureProject commit --quiet -m 'fixture'
  $overlayResult = (& $overlayScript -ProjectPath $fixtureProject -BaseBranch main | ConvertFrom-Json)
  Assert-True ($overlayResult.baseBranch -eq 'main') 'Overlay must retain the selected base branch.'
  Assert-True (Test-Path (Join-Path $fixtureProject '.harness\config.json')) 'Overlay must create project harness config.'
  Assert-True (Test-Path (Join-Path $fixtureProject '.agents\skills\feature-orchestration\SKILL.md')) 'Overlay must install the Codex skill.'
  Assert-True (Test-Path (Join-Path $fixtureProject '.claude\skills\branch-integration\SKILL.md')) 'Overlay must install the Claude skill.'
  Assert-True (-not (Test-Path (Join-Path $fixtureProject '.agents\skills\personal-orchestration\SKILL.md'))) 'Overlay must not install the personal orchestration skill.'
  Assert-True ((Get-Content -Raw (Join-Path $fixtureProject 'AGENTS.md')) -notmatch 'personal-harness:start') 'Overlay must not modify the project AGENTS bridge.'
  Assert-True ((Get-Content -Raw (Join-Path $fixtureProject 'CLAUDE.md')) -notmatch 'personal-harness:start') 'Overlay must not modify the project CLAUDE bridge.'
} finally {
  if (Test-Path -LiteralPath $fixtureProject) {
    Remove-Item -LiteralPath $fixtureProject -Recurse -Force
  }
}

$globalScript = Join-Path $HarnessRoot 'scripts\sync-global-harness.ps1'
$globalFixture = Join-Path ([System.IO.Path]::GetTempPath()) "harness-global-$([guid]::NewGuid().ToString('N'))"
try {
  New-Item -ItemType Directory -Path $globalFixture | Out-Null
  $globalCodexInstructions = Join-Path $globalFixture 'codex-AGENTS.md'
  $globalClaudeInstructions = Join-Path $globalFixture 'claude-CLAUDE.md'
  $globalSettings = Join-Path $globalFixture 'settings.json'
  $existingHookSettings = [ordered]@{
    hooks = [ordered]@{
      UserPromptSubmit = @([ordered]@{ hooks = @(
        [ordered]@{ type = 'command'; command = 'keep-orca-hook' },
        [ordered]@{ type = 'command'; command = 'personal-entry-hook.ps1' }
      ) })
      PreToolUse = @([ordered]@{ hooks = @([ordered]@{ type = 'command'; command = 'personal-entry-hook.ps1' }) })
    }
  }
  Set-Content -LiteralPath $globalSettings -Value ($existingHookSettings | ConvertTo-Json -Depth 10) -Encoding utf8
  $globalResult = (& $globalScript -InstallRoot (Join-Path $globalFixture 'installed') -CodexSkillRoot (Join-Path $globalFixture 'codex') -ClaudeSkillRoot (Join-Path $globalFixture 'claude') -CodexInstructionPath $globalCodexInstructions -ClaudeInstructionPath $globalClaudeInstructions -ClaudeSettingsPath $globalSettings | ConvertFrom-Json)
  Assert-True ($globalResult.mode -eq 'external-global') 'Global installation must report external-global mode.'
  Assert-True (Test-Path (Join-Path $globalFixture 'installed\core\agent-routing.json')) 'Global installation must install Harness Core.'
  Assert-True (Test-Path (Join-Path $globalFixture 'installed\scripts\validate-feature-transition.ps1')) 'Global installation must install execution validators.'
  Assert-True (Test-Path (Join-Path $globalFixture 'codex\feature-orchestration\SKILL.md')) 'Global installation must install Codex skills.'
  Assert-True (Test-Path (Join-Path $globalFixture 'claude\branch-integration\SKILL.md')) 'Global installation must install Claude skills.'
  Assert-True (Test-Path $globalCodexInstructions) 'Global installation must install the Codex entrypoint bridge.'
  Assert-True (Test-Path $globalClaudeInstructions) 'Global installation must install the Claude entrypoint bridge.'
  $globalCodexText = Get-Content -Raw $globalCodexInstructions
  $globalClaudeText = Get-Content -Raw $globalClaudeInstructions
  Assert-True ($globalCodexText -match 'first behavior-changing request') 'Codex entrypoint bridge must trigger bootstrap for behavior-changing requests.'
  Assert-True ($globalClaudeText -match 'first behavior-changing request') 'Claude entrypoint bridge must trigger bootstrap for behavior-changing requests.'
  Assert-True ($globalClaudeText -match '(?i)config\.json') 'Claude entrypoint bridge must identify the activation config.'
  Assert-True ($globalClaudeText -match '(?i)follow.*project|project.*instructions') 'Claude entrypoint bridge must fall back to project instructions when inactive.'
  Assert-True ($globalClaudeText -match 'Do not ask the user to run') 'Claude entrypoint bridge must not delegate bootstrap to the user.'
  Assert-True ($globalResult.activation.enabled -eq $true) 'Global installation must explicitly enable the personal harness.'
  Assert-True ($globalResult.activation.fallback -eq 'project-instructions') 'Global installation must declare the project-instructions fallback.'
  $settingsText = Get-Content -Raw $globalSettings
  Assert-True ($settingsText -notmatch 'personal-entry-hook\.ps1') 'Global installation must remove the Claude personal entry hook.'
  Assert-True ($settingsText -match 'keep-orca-hook') 'Global installation must preserve unrelated Claude hooks.'
  $settingsObject = $settingsText | ConvertFrom-Json
  Assert-True ((@($settingsObject.hooks.UserPromptSubmit | ForEach-Object { $_.hooks } | ForEach-Object { $_.command }) -join "`n") -match 'keep-orca-hook') 'UserPromptSubmit must preserve unrelated hooks.'
  Assert-True ($null -eq $settingsObject.hooks.PreToolUse) 'Empty personal PreToolUse hook groups must be removed.'
} finally {
  if (Test-Path -LiteralPath $globalFixture) {
    Remove-Item -LiteralPath $globalFixture -Recurse -Force
  }
}

Write-Output 'PASS: harness contract'
