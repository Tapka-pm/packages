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

if (-not (Test-Path -LiteralPath $Installer -PathType Leaf)) {
    throw "PortableGit installer not found: $Installer"
}

$installerPath = (Resolve-Path -LiteralPath $Installer).ProviderPath
$destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
[IO.Directory]::CreateDirectory($destinationPath) | Out-Null
if ([IO.Directory]::GetFileSystemEntries($destinationPath).Length -ne 0) {
    throw "PortableGit requires an empty staging directory: $destinationPath"
}

$startInfo = [Diagnostics.ProcessStartInfo]::new($installerPath)
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.WorkingDirectory = [IO.Path]::GetDirectoryName($installerPath)
$startInfo.ArgumentList.Add('-y')
$startInfo.ArgumentList.Add('-o')
$startInfo.ArgumentList.Add($destinationPath)

$process = [Diagnostics.Process]::Start($startInfo)
try {
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
        throw "PortableGit extraction failed (exit code $($process.ExitCode))."
    }
} finally {
    $process.Dispose()
}

if (-not [IO.File]::Exists((Join-Path $destinationPath 'cmd\git.exe')) -or
    -not [IO.File]::Exists((Join-Path $destinationPath 'ucrt64\bin\git.exe')) -or
    [IO.File]::Exists((Join-Path $destinationPath 'post-install.bat'))) {
    throw 'PortableGit extraction did not produce a complete installation.'
}
