#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Installer,

    [Parameter(Mandatory)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'

if (-not $IsWindows) {
    throw 'PortableGit requires Windows.'
}

$destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
$postInstall = Join-Path $destinationPath 'post-install.bat'
if (-not [IO.File]::Exists($postInstall)) {
    throw "PortableGit post-install script not found: $postInstall"
}

function Invoke-PortableGitStep {
    param([string]$Executable, [string[]]$Arguments, [string]$Step)

    $startInfo = [Diagnostics.ProcessStartInfo]::new($Executable)
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.WorkingDirectory = $destinationPath
    # The batch's helper scripts invoke git by name.
    $bin = Join-Path $destinationPath 'ucrt64\bin'
    $startInfo.Environment['PATH'] = "$bin;$env:PATH"
    $null = $startInfo.Environment.Remove('GIT_EXEC_PATH')
    foreach ($argument in $Arguments) {
        $startInfo.ArgumentList.Add($argument)
    }

    $process = [Diagnostics.Process]::Start($startInfo)
    try {
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) {
            throw "PortableGit $Step failed (exit code $($process.ExitCode))."
        }
    } finally {
        $process.Dispose()
    }
}

# Run a copy because the batch deletes post-install.bat before cmd finishes reading it.
$batchName = [IO.Path]::GetRandomFileName() + '.bat'
$batchCopy = Join-Path $destinationPath $batchName
[IO.File]::Copy($postInstall, $batchCopy)
try {
    $cmd = Join-Path ([Environment]::SystemDirectory) 'cmd.exe'
    Invoke-PortableGitStep -Executable $cmd -Arguments @('/d', '/v:off', '/c', ".\$batchName") -Step 'post-install'
} finally {
    [IO.File]::Delete($batchCopy)
}

foreach ($file in 'cmd\git.exe', 'ucrt64\bin\git.exe') {
    if (-not [IO.File]::Exists((Join-Path $destinationPath $file))) {
        throw "PortableGit post-install did not produce '$file'."
    }
}
if ([IO.File]::Exists($postInstall) -or [IO.Directory]::Exists((Join-Path $destinationPath 'etc\post-install'))) {
    throw 'PortableGit did not finish cleaning up its post-install scripts.'
}

$git = Join-Path $destinationPath 'cmd\git.exe'
Invoke-PortableGitStep -Executable $git -Arguments @('--version') -Step 'version check'
