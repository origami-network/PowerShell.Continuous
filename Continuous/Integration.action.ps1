#Requires -Version 3.0
#Requires -Modules Pester

[CmdletBinding()]
param (
	[Parameter(Position = 0, Mandatory = $true)]
	[string]
	$WorkspacePath,
	[String]
	$ProjectPath = (Split-Path $MyInvocation.MyCommand.Path -Parent),

	[string]
	$NuGetFilePath = (Join-Path $WorkspacePath '.nuget\nuget.exe'),

	[string]
	$ArtifactPath = (Join-Path $WorkspacePath '.artifacts')
)

if (Test-Path $ArtifactPath) {
	Write-Verbose "Clean artifacts."
	Remove-Item $ArtifactPath -Recurse -Force
}
$reportPath = (Join-Path $ArtifactPath "Reports")
New-Item $reportPath -ItemType Directory -Force | Out-Null
$packagePath = (Join-Path $ArtifactPath "Packages")
New-Item $packagePath -ItemType Directory -Force | Out-Null

function Invoke-IntegrationTest {
	param (
		$Path,
		
		$Name,
		$OutputPath
	)

	$parameters = @{
		Script = @{
			Path = (Join-Path $Path "*")
		}
		OutputFile = (Join-Path $OutputPath "PowerShell.$Name.NUnit.xml")
	}
	Invoke-Pester @parameters
}

function Invoke-IntegrationPackage {
	param (
		$NuspecPath,

		$NuGet,

		$OutputPath
	)

	Get-Item (Join-Path $NuspecPath "*.nuspec") |
		% {
			& $NuGet pack $_.FullName -outputdirectory $OutputPath
		}
}

Write-Progress "Integration" "Test"
Invoke-IntegrationTest -Path (Join-Path $ProjectPath "tests") -Name "Continuous" -OutputPath $reportPath
Write-Progress "Integration" "Package"
Invoke-IntegrationPackage -NuspecPath $ProjectPath -NuGet $NuGetFilePath -OutputPath $packagePath
