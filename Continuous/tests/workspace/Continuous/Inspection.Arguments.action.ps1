#Requires -Version 3.0

[CmdletBinding()]
param (
	[string]
	$WorkspacePath,
	[string]
	$ActionPath,
	[string]
	$PackagePath,
	[string]
	$ModulePath,
	[string]
	$NuGetFilePath,

	[string]
	$DefaultTextParameter = "Default Text Value",
	[string]
	$TextParameter,
	[switch]
	$SwitchParameter
)

if (Get-Command "Set-InspectionValue" -ErrorAction Ignore) {
	Set-InspectionValue "WorkspacePath" $WorkspacePath
	Set-InspectionValue "ActionPath" $ActionPath
	Set-InspectionValue "PackagePath" $PackagePath
	Set-InspectionValue "ModulePath" $ModulePath
	Set-InspectionValue "NuGetFilePath" $NuGetFilePath

	Set-InspectionValue "DefaultTextParameter" $DefaultTextParameter
	Set-InspectionValue "TextParameter" $TextParameter
	Set-InspectionValue "SwitchParameter" $SwitchParameter
}

