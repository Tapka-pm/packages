#Requires -Version 7.0

param(
    [Parameter(Mandatory)]
    [string]$Installer,
    [Parameter(Mandatory)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
if (-not [IO.Path]::IsPathFullyQualified([string]$env:TAPKA_7ZR)) {
    throw 'Tapka did not provide the managed 7zr.exe.'
}
& $env:TAPKA_7ZR x -y -bso0 -bsp0 "-o$Destination" -- $Installer 7z.exe 7z.dll License.txt readme.txt
if ($LASTEXITCODE -ne 0) {
    throw "7-Zip bootstrap extraction failed (exit code $LASTEXITCODE)."
}
