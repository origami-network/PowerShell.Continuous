#Requires -Version 3.0

[CmdletBinding()]
param (
	[Parameter(Position = 0, Mandatory = $true)]
	[string]
	$WorkspacePath,

	[string]
	$NuGetFilePath = (Join-Path $WorkspacePath '.nuget\nuget.exe'),
	[string]
	$NuGetSource = "https://www.nuget.org/api/v2/package",
	[string]
	$NuGetApiKey,

	[string]
	$ArtifactPath = (Join-Path $WorkspacePath '.artifacts')
)

function Invoke-Publish {
	param (
		$NuGet,
		$ApiKey,
		$Source,

		$PackagePath
	)

	if ($ApiKey) {
		& $NuGet push (Join-Path $PackagePath "*.nupkg") -ApiKey $ApiKey -Source $Source
	} else {
		& $NuGet push  -Source $Source		
	}

	if ($LastExitCode) {
		Write-Error "NuGet push failed with error code $($LastExitCode)."
	}
}

Write-Progress "Delivery" "Publish"
$packagePath = (Join-Path $ArtifactPath "Packages")
Invoke-Publish -NuGet $NuGetFilePath -ApiKey $NuGetApiKey -Source $NuGetSource -PackagePath $packagePath
