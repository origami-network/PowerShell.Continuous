#Requires -Version 3.0

[CmdletBinding()]
param (
)

if (Get-Command "Set-InspectionValue" -ErrorAction Ignore) {
	Set-InspectionValue "env:PSModulePath" $env:PSModulePath
}

