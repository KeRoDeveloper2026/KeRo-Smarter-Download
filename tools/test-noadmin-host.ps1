param([Parameter(Mandatory)][string]$Platform)
$ErrorActionPreference='Stop'
if($env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_ENVIRONMENT -ne 'github-hosted'){throw 'Requires a disposable hosted Windows runner'}
$name='KeRoStdTest'
# Random credential remains in process memory; never print or pass it as an argument.
$password='Kr!'+[guid]::NewGuid().ToString('N')+'7a'
$secure=ConvertTo-SecureString $password -AsPlainText -Force
$credential=New-Object Management.Automation.PSCredential("$env:COMPUTERNAME\$name",$secure)
$user=New-LocalUser -Name $name -Password $secure -PasswordNeverExpires
$users=(New-Object Security.Principal.SecurityIdentifier('S-1-5-32-545')).Translate([Security.Principal.NTAccount]).Value.Split('\')[-1]
if (-not (Get-LocalGroupMember -Group $users | Where-Object { $_.SID -eq $user.SID })) { Add-LocalGroupMember -Group $users -Member $name }
$shared=Join-Path $env:PUBLIC ('KeRo-NoAdmin-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $shared | Out-Null
icacls $shared /grant "*$($user.SID.Value):(OI)(CI)M" | Out-Null
if($LASTEXITCODE -ne 0){throw 'Cannot grant test account access to fixture folder'}
$candidate=Get-ChildItem "dist/*NoAdmin*-$Platform.exe" | Select-Object -First 1
if(-not $candidate){throw 'Candidate installer missing'}
Copy-Item $candidate.FullName "$shared/candidate.exe"
Copy-Item (Get-Content "dist/PREVIOUS-$Platform.txt" -Raw) "$shared/previous.exe"
Copy-Item tools/test-noadmin-child.ps1 "$shared/test.ps1"
$hash=(Get-FileHash build-cache/stage/KeRoDownload.exe).Hash
try {
    $args=@('-NoProfile','-ExecutionPolicy','Bypass','-File',"$shared/test.ps1",'-Candidate',"$shared/candidate.exe",'-Previous',"$shared/previous.exe",'-Output',"$shared/result.json",'-ExpectedAppHash',$hash)
    $p=Start-Process "$env:WINDIR/System32/WindowsPowerShell/v1.0/powershell.exe" -Credential $credential -LoadUserProfile -ArgumentList $args -WorkingDirectory $shared -PassThru -Wait
    if(-not(Test-Path "$shared/result.json")){throw 'Standard-user process did not produce a report'}
    Copy-Item "$shared/result.json" "dist/NONADMIN-$Platform.json"
    Get-ChildItem "$shared/*.log" | Copy-Item -Destination dist
    $r=Get-Content "$shared/result.json" -Raw | ConvertFrom-Json
    if($p.ExitCode -ne 0 -or $r.error){throw "Standard-user checks failed: $($r.error)"}
    Write-Host 'Standard-user install, upgrade, silent installer arguments and uninstall checks passed.'
} finally {
    # Account and artifacts exist only on this disposable CI machine.
    Remove-LocalUser -Name $name -ErrorAction SilentlyContinue
    $password=$null;$credential=$null
}
