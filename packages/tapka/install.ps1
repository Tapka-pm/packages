#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Installer,

    [Parameter(Mandatory)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'

$installerPath = (Resolve-Path -LiteralPath $Installer).ProviderPath
$destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
[IO.Directory]::CreateDirectory($destinationPath) | Out-Null
[IO.File]::Copy($installerPath, (Join-Path $destinationPath 'tapka.exe'))
