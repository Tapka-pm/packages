#Requires -Version 7.0

param(
    [Parameter(Mandatory)]
    [string]$Installer,
    [Parameter(Mandatory)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
[IO.File]::Copy($Installer, (Join-Path $Destination '7zr.exe'))
