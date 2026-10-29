param([Parameter(Mandatory)][ValidateSet('Validate','Prepare','Sign','Publish')][string]$Phase)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$plan = Get-Content .github/releases/v1.1.4.json -Raw | ConvertFrom-Json
$version = $plan.version
$tag = "v$version"
$repo = $env:GITHUB_REPOSITORY
if ($repo -ne 'KeRoDeveloper2026/KeRo-Smarter-Download' -or $env:GITHUB_REF -ne 'refs/heads/main') {
    throw 'Promotion is restricted to the reviewed main branch in the original repository'
}
function Api([string]$Path) {
    $raw = gh api "repos/$repo/$Path"
    if ($LASTEXITCODE -ne 0) { throw "GitHub API request failed: $Path" }
    return ($raw | ConvertFrom-Json)
}
function Hash([string]$Path) { return (Get-FileHash $Path -Algorithm SHA256).Hash.ToLower() }
function Check-Installers {
    foreach ($item in $plan.installers) {
        if ((Hash "dist/$($item.file)") -ne $item.sha256) { throw "Tested installer mismatch: $($item.file)" }
        $info = Get-Content "dist/BUILD-INFO-$($item.platform).txt" -Raw
        if (-not $info.Contains($plan.source_sha)) { throw 'Candidate source provenance mismatch' }
        if (-not (Get-Content "dist/UPGRADE-$($item.platform).txt" -Raw).StartsWith('PASS:')) { throw 'Missing successful upgrade report' }
    }
}
if ($Phase -eq 'Validate') {
    $tokens = $null; $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($PSCommandPath, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { throw 'Promotion script syntax error' }
    if (([regex]::Match((Get-Content Cargo.toml -Raw), '(?m)^version\s*=\s*"([^"]+)"')).Groups[1].Value -ne $version) { throw 'Workspace version mismatch' }
    git merge-base --is-ancestor $plan.source_sha HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Approved candidate must be an ancestor of main' }
    # Documentation and publication tooling may change; built inputs must not.
    git diff --exit-code $plan.source_sha HEAD -- Cargo.toml Cargo.lock .cargo crates extension extension-firefox installer tools/ffmpeg tools/prepare-win7.py tools/package-platform.ps1 repair-ffmpeg.ps1 REPAIR-FFMPEG.bat LICENSE COPYRIGHT THIRD-PARTY-NOTICES.txt
    if ($LASTEXITCODE -ne 0) { throw 'Application build inputs differ from the tested candidate' }
    foreach ($runId in @($plan.preview_run, $plan.quality_run)) {
        $run = Api "actions/runs/$runId"
        if ($run.head_sha -ne $plan.source_sha -or $run.status -ne 'completed' -or $run.conclusion -ne 'success') { throw 'Approved validation run is not successful for the expected source' }
    }
    $artifacts = (Api "actions/runs/$($plan.preview_run)/artifacts?per_page=100").artifacts
    foreach ($expected in $plan.artifacts) {
        $actual = @($artifacts | Where-Object id -eq $expected.id)
        if ($actual.Count -ne 1 -or $actual[0].name -ne $expected.name -or $actual[0].digest -ne $expected.digest -or $actual[0].expired) { throw 'Approved artifact metadata mismatch' }
    }
    Write-Host 'Approved source, checks and artifact identities verified; no application build required'
    return
}
if ($Phase -eq 'Prepare') {
    Check-Installers
    New-Item -ItemType Directory -Force support | Out-Null
    foreach ($asset in $plan.support_assets) {
        gh release download $plan.support_release --repo $repo --pattern $asset.name --dir support
        if ($LASTEXITCODE -ne 0 -or (Hash "support/$($asset.name)") -ne $asset.sha256) { throw "Support asset mismatch: $($asset.name)" }
        Copy-Item "support/$($asset.name)" dist/
    }
    # Compatibility alias is byte-for-byte identical to the clearly named x64 EXE.
    Copy-Item 'dist/KeRoDownload-v1.1.4-Win10_11-x64.exe' 'dist/KeRoDownload-Setup.exe'
    if ((Hash dist/KeRoDownload-Setup.exe) -ne $plan.installers[0].sha256) { throw 'Compatibility alias mismatch' }
    $provenance = @{ version=$version; source=$plan.source_sha; release_commit=$env:GITHUB_SHA; preview_run=$plan.preview_run; quality_run=$plan.quality_run; installers=$plan.installers; support_source=$plan.support_release; support_assets=$plan.support_assets; note='Exact approved installers promoted without rebuilding or repackaging; all runtime CI tests ran on Windows Server 2022. Windows 7 remains experimental.' }
    $provenance | ConvertTo-Json -Depth 12 | Set-Content dist/PROVENANCE.json -Encoding utf8NoBOM
    return
}
if ($Phase -eq 'Sign') {
    # The only child process exposed to the key is our existing compiled signer.
    Check-Installers
    try {
        if (-not $env:UPDATE_SIGNING_KEY) { throw 'UPDATE_SIGNING_KEY is required' }
        foreach ($item in $plan.installers) {
            $sig = (& ./target/debug/examples/sign_update.exe $version $item.sha256).Trim()
            if ($LASTEXITCODE -ne 0 -or $sig -notmatch '^[0-9a-f]{128}$') { throw 'Update signature validation failed' }
            $manifest = @{ version=$version; url="https://github.com/$repo/releases/download/$tag/$($item.file)"; sha256=$item.sha256; sig=$sig }
            $manifest | ConvertTo-Json | Set-Content "dist/$($item.manifest)" -Encoding utf8NoBOM
        }
    } finally {
        Remove-Item Env:UPDATE_SIGNING_KEY -ErrorAction SilentlyContinue
    }
    $lines = @(Get-ChildItem dist -File | Where-Object Name -ne 'SHA256SUMS.txt' | Sort-Object Name | ForEach-Object { "$(Hash $_.FullName)  $($_.Name)" })
    [IO.File]::WriteAllText("$PWD/dist/SHA256SUMS.txt", ($lines -join "`n") + "`n")
    Write-Host 'All four update manifests signed and self-verified by the existing Rust verifier'
    return
}
# Publication has no signing secret and can be retried independently of preparation.
Check-Installers
foreach ($line in Get-Content dist/SHA256SUMS.txt) {
    if ($line -notmatch '^([0-9a-f]{64})  ([^/\\]+)$') { throw 'Invalid checksum entry' }
    if ((Hash "dist/$($Matches[2])") -ne $Matches[1]) { throw 'Retained release payload checksum mismatch' }
}
$latest = Api 'releases/latest'
if ([version]$latest.tag_name.TrimStart('v') -gt [version]$version) { throw 'Refusing to replace a newer Latest release' }
$refRaw = gh api "repos/$repo/git/ref/tags/$tag" 2>$null
if ($LASTEXITCODE -eq 0) {
    $tagCommit = (Api "commits/$tag").sha
    if ($tagCommit -ne $env:GITHUB_SHA) { throw 'Existing tag points to a different release commit' }
} else {
    # Use only GITHUB_TOKEN: the created tag does not start another native build.
    gh api --method POST "repos/$repo/git/refs" -f "ref=refs/tags/$tag" -f "sha=$env:GITHUB_SHA" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not create release tag' }
}
$releaseRaw = gh api "repos/$repo/releases/tags/$tag" 2>$null
if ($LASTEXITCODE -eq 0) { $release = $releaseRaw | ConvertFrom-Json } else {
    gh release create $tag --repo $repo --verify-tag --draft --title "KeRo Smarter Download $version" --generate-notes --notes-file docs/RELEASE-v1.1.4.md
    if ($LASTEXITCODE -ne 0) { throw 'Could not create draft release' }
    $release = Api "releases/tags/$tag"
}
$files = @(Get-ChildItem dist -File)
foreach ($file in $files) {
    $existing = @($release.assets | Where-Object name -eq $file.Name)
    if ($existing.Count) {
        if ($existing.Count -ne 1 -or $existing[0].digest -ne "sha256:$(Hash $file.FullName)") { throw "Existing release asset differs: $($file.Name)" }
        continue
    }
    if (-not $release.draft) { throw 'Published release is incomplete; refusing to silently alter it' }
    gh release upload $tag $file.FullName --repo $repo
    if ($LASTEXITCODE -ne 0) { throw "Could not upload $($file.Name); retry the publication job only" }
}
$release = Api "releases/tags/$tag"
if ($release.assets.Count -ne $files.Count) { throw 'Unexpected release asset count' }
foreach ($file in $files) {
    $asset = @($release.assets | Where-Object name -eq $file.Name)
    if ($asset.Count -ne 1 -or $asset[0].digest -ne "sha256:$(Hash $file.FullName)") { throw 'Uploaded release payload verification failed' }
}
if ($release.draft) {
    gh release edit $tag --repo $repo --draft=false --latest
    if ($LASTEXITCODE -ne 0) { throw 'Could not publish verified draft; retry publication only' }
}
$published = Api "releases/tags/$tag"
if ($published.draft -or $published.prerelease -or (Api 'releases/latest').tag_name -ne $tag) { throw 'Published release state verification failed' }
Write-Host "Published $tag with exact approved installer hashes"
