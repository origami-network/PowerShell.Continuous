#Requires -Version 3.0

[CmdletBinding()]
param (
)

if (Get-Command "Set-ActionPSModulePath") {
	Set-ActionPSModulePath $env:PSModulePath
}

