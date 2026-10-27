$ErrorActionPreference = 'Stop'

$expectedRemote = 'https://github.com/kevs-mist/KTECH_PROJECT_004_DEMO.git'
$plan = @(
    @{ Branch = 'ui'; Kind = 'main' },
    @{ Branch = 'backend'; Kind = 'main' },
    @{ Branch = 'ui-screens'; Kind = 'sub' },
    @{ Branch = 'ui-components'; Kind = 'sub' },
    @{ Branch = 'mock-api'; Kind = 'main' }
)

$root = (& git rev-parse --show-toplevel).Trim()
if ($LASTEXITCODE -ne 0 -or -not $root) { throw 'Run this script from inside the repository.' }
Set-Location $root

$remote = (& git remote get-url origin 2>$null)
if ($LASTEXITCODE -ne 0 -or $remote.TrimEnd('/') -ne $expectedRemote.TrimEnd('/')) {
    throw "origin must point to $expectedRemote"
}

$gitDir = (& git rev-parse --git-dir).Trim()
if (-not [System.IO.Path]::IsPathRooted($gitDir)) { $gitDir = Join-Path $root $gitDir }
$statePath = Join-Path $gitDir 'push-next-state.json'
$state = if (Test-Path $statePath) { Get-Content $statePath -Raw | ConvertFrom-Json } else { [pscustomobject]@{ pushes = @() } }
$pushes = @($state.pushes)
$pushedBranches = @($pushes | ForEach-Object { $_.branch })
$next = $plan | Where-Object { $pushedBranches -notcontains $_.Branch } | Select-Object -First 1

if (-not $next) {
    Write-Output 'All scheduled feature branches have been pushed.'
    exit 0
}

$today = Get-Date -Format 'yyyy-MM-dd'
$todayPushes = @($pushes | Where-Object { $_.date -eq $today })
$mainCount = @($todayPushes | Where-Object { $_.kind -eq 'main' }).Count
$subCount = @($todayPushes | Where-Object { $_.kind -eq 'sub' }).Count
if ($next.Kind -eq 'main' -and $mainCount -ge 1) {
    throw 'Daily limit reached: only one main-level feature branch may be pushed per day.'
}
if ($next.Kind -eq 'sub' -and $subCount -ge 2) {
    throw 'Daily limit reached: only two UI sub-branches may be pushed per day.'
}

& git show-ref --verify --quiet "refs/heads/$($next.Branch)"
if ($LASTEXITCODE -ne 0) { throw "Local branch '$($next.Branch)' does not exist. Create it from PUSH_PLAN.md first." }

Write-Output "Pushing $($next.Branch) to origin on $today."
& git push --set-upstream origin $next.Branch
if ($LASTEXITCODE -ne 0) { throw "Push failed for '$($next.Branch)'; local state was not updated." }

$newPushes = @($pushes) + @([pscustomobject]@{ date = $today; branch = $next.Branch; kind = $next.Kind })
@{ pushes = $newPushes } | ConvertTo-Json -Depth 5 | Set-Content -Path $statePath -Encoding utf8
Write-Output "Recorded successful push in $statePath."