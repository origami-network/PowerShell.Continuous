param (
	[string]
	$Here = (Split-Path -Parent $MyInvocation.MyCommand.Path),
	
	[string]
	$InvokeContinuousSourceFilePath = (Join-Path ($Here | Split-Path -Parent | Split-Path -Parent) "Invoke-Continuous.ps1"),
	
	[string]
	$NuGetFeedPath = (Join-Path $Here "feed"),
	[string]
	$NuGetConfigTemplateFilePath = (Join-Path $Here "nuget\NuGet.Config.template"),
	[string]
	$NuGetSourceFilePath = (Join-Path ($Here | Split-Path -Parent | Split-Path -Parent) ".nuget\NuGet.exe"),

	[string]
	$WorkspaceSourcePath = (Join-Path $Here "workspace")
)

function Copy-NuGetConfig {
	param (
		$SourceFilePath,
		$TargetPath,

		$FeedPath
	)

	New-Item (Join-Path $TargetPath ".nuget") -ItemType Directory -Force |
		Out-Null
	Get-Content $SourceFilePath |
		% { $_ -replace "{{FeedPath}}", $FeedPath} |
		Set-Content (Join-Path $TargetPath "NuGet.Config")
}

New-Module -ScriptBlock {
	$script:inspectionValues = @{}

	function Set-InspectionValue {
		param ($Name, $Value)
		$script:inspectionValues.Add($Name, $Value)
	}

	function Get-InspectionValue {
		param ($Name)

		return $script:inspectionValues[$Name]
	}

	function Reset-InspectionValues {
		$script:inspectionValues = @{}
	}
}

Describe "Bootstraps workspace" {
	$nuGetPath = Join-Path $TestDrive ".nuget"

	Copy-Item $InvokeContinuousSourceFilePath $TestDrive
	
	Copy-Item (Join-Path $WorkspaceSourcePath "**") $TestDrive -Recurse
	
	Copy-NuGetConfig $NuGetConfigTemplateFilePath $nuGetPath $NuGetFeedPath
	Copy-Item $NuGetSourceFilePath $nuGetPath

	Context "clean environment" {
	
		Reset-InspectionValues
		Remove-Item (Join-Path $nuGetPath "nuget.exe")

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Inspection -Verbose

		It "downloads NuGet.exe" {
			$nugetFilePath = Join-Path $nuGetPath "nuget.exe"

			Test-Path $nugetFilePath | Should be $true
		}

		It "restores NuGet packages" {
			$packagePath = Join-Path $TestDrive "packages"
			$packageMeasure = (Get-ChildItem $packagePath | measure)

			Test-Path $packagePath | Should be $true
			Test-Path $packageMeasure.Count | Should be 2
		}

		It "creates PowerShell modules form NuGet packages" {
			$modulePath = Join-Path $TestDrive ".modules"
			$moduleMeasure = (Get-ChildItem $packagePath | measure)

			Test-Path $modulePath | Should be $true
			Test-Path $moduleMeasure.Count | Should be 1
		}

		It "extends PowerShell modules path with workspace" {
			$modulePath = $TestDrive
			$modulePaths = (Get-InspectionValue 'env:PSModulePath') -split ";"

			$modulePaths -contains $modulePath | Should be $true 
		}

		It "extends PowerShell modules path witch modules from NuGet packages" {
			$modulePath = Join-Path $TestDrive ".modules" 
			$modulePaths = (Get-InspectionValue 'env:PSModulePath') -split ";" 

			$modulePaths -contains $modulePath | Should be $true 
		}

		It "removes workspace from PowerShell modules path" {
			$modulePath = $TestDrive
			$modulePaths = $env:PSModulePath -split ";"

			$modulePaths -contains $modulePath | Should be $false 
		}

		It "removes modules from NuGet packages from PowerShell modules path" {
			$modulePath = Join-Path $TestDrive ".modules" 
			$modulesPaths = $actionPSModulePath -split ";" 

			$modulePaths -contains $modulePath | Should be $false 			
		}
	}

	Context "cleaning environment was forced" {
		
		$fakePackageContentFile = Join-Path $TestDrive "packages\Fake.Package-0.1.0\Content\Fake.txt"
		New-Item  (Split-Path $fakePackageContentFile -Parent) -ItemType Directory -Force |
			Out-Null
		Set-Content $fakePackageContentFile -Value ""
		$fakeModuleManifestFilePath = Join-Path $TestDrive ".modules\Fake.Module\0.1.0\Fake.Module.psd1"
		New-Item  (Split-Path $fakeModuleManifestFilePath -Parent) -ItemType Directory -Force |
			Out-Null
		Set-Content $fakeModuleManifestFilePath -Value ""

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Nothing -Clean -Verbose

		It "deletes NuGet packages folder" {
			for (
				$filePath = $fakePackageContentFile
				$filePath -ne $TestDrive
				$filePath = Split-Path $filePath -Parent
			) {
				Write-Host $filePath
			
				Test-Path $filePath | Should be $false
			}
		}

		It "deletes created PowerShell modules folder" {
			for (
				$filePath = $fakeModuleManifestFilePath
				$filePath -ne $TestDrive
				$filePath = Split-Path $filePath -Parent
			) {
				Write-Host $filePath

				Test-Path $filePath | Should be $false
			}			
		}
	}

	Context "nuget.exe already exists" {
		
		$lastModifiedDate = (Get-Date).AddYears(10);

		# TODO: prepare other artifacts
		# TODO: set nuget.exe file modified date
		# TODO: Use mock method to get values from actions script 

		It "use existing nuget.exe" {
			throw "Not implemented" 

			#TODO: compare nuget.exe file
			#TODO: check value			
		}
	}

	Context "finished with error" {

		# TODO: prepare other artifacts
		# TODO: error action
		# TODO: Use mock method to get values from actions script
		# TODO: Execute script an cache error

		It "removes workspace from PowerShell modules path" {
			$modulePath = $TestDrive
			$modulePaths = $env:PSModulePath -split ";"

			$modulePaths -contains $modulePath | Should be $false 
		}

		It "removes modules from NuGet packages from PowerShell modules path" {
			$modulePath = Join-Path $TestDrive ".modules" 
			$modulesPaths = $actionPSModulePath -split ";" 

			$modulePaths -contains $modulePath | Should be $false 			
		}
	}
}

Describe "Executes action" {

	Copy-Item $InvokeContinuousSourceFilePath $TestDrive

	Context "action has arguments" {
		
		#TODO: prepare other artifacts
		#TODO: Mock method to store action arguments
		#TODO: Invoke continuous action

		It "passes default script arguments to action" {
			throw "Not implemented" 

			$actionPSBoundParameters.WorkspacePath | Should be $TestDrive
			$actionPSBoundParameters.ActionPath | Should be (Join-Path $TestDrive "Continuous")
			$actionPSBoundParameters.PackagePath | Should be (Join-Path $TestDrive "packages")
			$actionPSBoundParameters.ModulePath | Should be (Join-Path $TestDrive "modules")
			$actionPSBoundParameters.NuGetFilePath | Should be (Join-Path $TestDrive ".nuget\nuget.exe")
		}

		It "passes specific arguments to action" {
			$actionPSBoundParameters.TextParameter | Should be "Text Value"
			$actionPSBoundParameters.SwitchParameter | Should be $true
		}
	}

	Context "exiting on error was forced" {
		
		$powershellExitCode = 0

		#TODO: prepare other artifacts
		#TODO: Mock method to store action arguments
		#TODO: Invoke continuous action process with error and force exit
		#TODO: Store last error code

		It "exits PowerShell process with non zeros status code" {
			$powershellExitCode | Should Not Be 0
		}
	}
}
