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

function Invoke-Test {
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
	
	$result = Invoke-Pester @parameters -PassThru
	
	if ($result.FailedCount) {
		throw "Some tests ware failed"
	}
}

function Invoke-Package {
	param (
		$NuspecPath,

		$NuGet,

		$OutputPath
	)

	Get-Item (Join-Path $NuspecPath "*.nuspec") |
		% {
			& $NuGet pack $_.FullName -outputdirectory $OutputPath
			
			if ($LastExitCode) {
				Write-Error "NuGet pack failed with error code $($LastExitCode)."
			}
		}
}

if (Test-Path $ArtifactPath) {
	Write-Progress "Integration" "Clean artifacts"
	Remove-Item $ArtifactPath -Recurse -Force
}

Write-Progress "Integration" "Test"
$reportPath = (Join-Path $ArtifactPath "Reports")
New-Item $reportPath -ItemType Directory -Force | Out-Null
Invoke-Test -Path (Join-Path $ProjectPath "tests") -Name "Continuous" -OutputPath $reportPath

Write-Progress "Integration" "Package"
$packagePath = (Join-Path $ArtifactPath "Packages")
New-Item $packagePath -ItemType Directory -Force | Out-Null
Invoke-Package -NuspecPath $ProjectPath -NuGet $NuGetFilePath -OutputPath $packagePath
