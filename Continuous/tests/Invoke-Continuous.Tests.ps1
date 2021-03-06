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
	$nuGetFilePath = Join-Path $nuGetPath "NuGet.exe"
	$packagePath = Join-Path $TestDrive "packages"
	$modulePath = Join-Path $TestDrive ".modules"

	Copy-Item $InvokeContinuousSourceFilePath $TestDrive
	Copy-Item (Join-Path $WorkspaceSourcePath "**") $TestDrive -Recurse	
	Remove-Item (Join-Path $TestDrive "*.sln")
	Copy-NuGetConfig $NuGetConfigTemplateFilePath $nuGetPath $NuGetFeedPath

	Context "clean environment" {
	
		Reset-InspectionValues

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Inspection -Verbose

		It "downloads NuGet.exe" {
			Test-Path $nugetFilePath | Should be $true
		}

		It "restores NuGet packages" {
			$packageMeasure = (Get-ChildItem $packagePath | measure)

			Test-Path $packagePath | Should be $true
			$packageMeasure.Count | Should be 2
		}

		It "creates PowerShell modules form NuGet packages" {
			$moduleMeasure = (Get-ChildItem $modulePath | measure)

			Test-Path $modulePath | Should be $true
			$moduleMeasure.Count | Should be 1
		}

		It "extends PowerShell modules path with workspace" {
			$modulePath = $TestDrive
			$modulePaths = (Get-InspectionValue 'env:PSModulePath') -split ";"

			$modulePaths -contains $modulePath | Should be $true 
		}

		It "extends PowerShell modules path witch modules from NuGet packages" {
			$modulePaths = (Get-InspectionValue 'env:PSModulePath') -split ";" 

			$modulePaths -contains $modulePath | Should be $true 
		}

		It "removes workspace from PowerShell modules path" {
			$modulePath = $TestDrive
			$modulePaths = $env:PSModulePath -split ";"

			$modulePaths -contains $modulePath | Should be $false 
		}

		It "removes modules from NuGet packages from PowerShell modules path" {
			$modulesPaths = $actionPSModulePath -split ";" 

			$modulePaths -contains $modulePath | Should be $false 			
		}
	}

	Context "nuget.exe already exists" {
		
		Copy-Item $NuGetSourceFilePath $nuGetPath

		$date = (Get-Date).AddYears(10);
		$nugetFileHash = (Get-FileHash $nuGetFilePath).Hash
		Get-Item $nuGetFilePath | % {
			$_.CreationTime = $date
			$_.LastWriteTime = $date
		}

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Nothing -Verbose

		It "use existing nuget.exe" {
			(Get-FileHash $nuGetFilePath).Hash | Should be $nugetFileHash
			Get-Item $nuGetFilePath | % {
				$_.CreationTime | Should be $date
				$_.LastWriteTime | Should be $date
			}			
		}
	}

	Context "cleaning environment was forced" {
		
		Copy-Item $NuGetSourceFilePath $nuGetPath

		$fakePackageContentFilePath = Join-Path $packagePath "Test.Fake.Package-0.1.0\Content\Fake.txt"
		New-Item  (Split-Path $fakePackageContentFilePath -Parent) -ItemType Directory -Force |
			Out-Null
		Set-Content $fakePackageContentFilePath -Value ""
		$fakeModuleManifestFilePath = Join-Path $modulePath "Test.Fake.Module\0.1.0\Fake.Module.psd1"
		New-Item  (Split-Path $fakeModuleManifestFilePath -Parent) -ItemType Directory -Force |
			Out-Null
		Set-Content $fakeModuleManifestFilePath -Value ""

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Nothing -Clean -Verbose

		It "deletes NuGet packages folder" {
			for (
				$filePath = $fakePackageContentFilePath
				$filePath -ne $packagePath
				$filePath = Split-Path $filePath -Parent
			) {
				Test-Path $filePath | Should be $false
			}
		}

		It "deletes created PowerShell modules folder" {
			for (
				$filePath = $fakeModuleManifestFilePath
				$filePath -ne $modulePath
				$filePath = Split-Path $filePath -Parent
			) {
				Test-Path $filePath | Should be $false
			}			
		}
	}	

	Context "finished with error" {

		Copy-Item $NuGetSourceFilePath $nuGetPath

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Exception -Clean -Verbose

		It "removes workspace from PowerShell modules path" {
			$modulePath = $TestDrive
			$modulePaths = $env:PSModulePath -split ";"

			$modulePaths -contains $modulePath | Should be $false 
		}

		It "removes modules from NuGet packages from PowerShell modules path" {
			$modulesPaths = $actionPSModulePath -split ";" 

			$modulePaths -contains $modulePath | Should be $false 			
		}
	}
}

Describe "Bootstraps packages from workspace" {
	$nuGetPath = Join-Path $TestDrive ".nuget"
	$nuGetFilePath = Join-Path $nuGetPath "NuGet.exe"
	$packagePath = Join-Path $TestDrive "packages"
	$modulePath = Join-Path $TestDrive ".modules"

	Copy-Item $InvokeContinuousSourceFilePath $TestDrive
	Copy-Item (Join-Path $WorkspaceSourcePath "**") $TestDrive -Recurse	
	Remove-Item (Join-Path $TestDrive "*.sln")
	Move-Item (Join-Path $TestDrive "Continuous/packages.config") $TestDrive
	Copy-NuGetConfig $NuGetConfigTemplateFilePath $nuGetPath $NuGetFeedPath

	Context "clean environment" {
	
		Reset-InspectionValues

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Nothing -Verbose

		It "restores NuGet packages" {
			$packageMeasure = (Get-ChildItem $packagePath | measure)

			Test-Path $packagePath | Should be $true
			$packageMeasure.Count | Should be 2
		}
	}
}

Describe "Bootstraps packages for solution" {
	$nuGetPath = Join-Path $TestDrive ".nuget"
	$nuGetFilePath = Join-Path $nuGetPath "NuGet.exe"
	$packagePath = Join-Path $TestDrive "packages"
	$modulePath = Join-Path $TestDrive ".modules"

	Copy-Item $InvokeContinuousSourceFilePath $TestDrive
	Copy-Item (Join-Path $WorkspaceSourcePath "**") $TestDrive -Recurse	
	Copy-NuGetConfig $NuGetConfigTemplateFilePath $nuGetPath $NuGetFeedPath

	Context "clean environment" {
	
		Reset-InspectionValues

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Nothing -Verbose

		It "restores NuGet packages" {
			$packageMeasure = (Get-ChildItem $packagePath | measure)

			Test-Path $packagePath | Should be $true
			$packageMeasure.Count | Should be 2
		}
	}
}

Describe "Executes action" {
	$nuGetPath = Join-Path $TestDrive ".nuget"
	$nuGetFilePath = Join-Path $nuGetPath "NuGet.exe"

	Copy-Item $InvokeContinuousSourceFilePath $TestDrive
	Copy-Item (Join-Path $WorkspaceSourcePath "**") $TestDrive -Recurse	
	Copy-NuGetConfig $NuGetConfigTemplateFilePath $nuGetPath $NuGetFeedPath
	Copy-Item $NuGetSourceFilePath $nuGetPath

	Context "action has arguments" {
		
		Reset-InspectionValues

		& (Join-Path $TestDrive "Invoke-Continuous.ps1") Inspection.Arguments -Verbose -TextParameter "Text Value" -SwitchParameter

		It "passes default script arguments to action" {
			Get-InspectionValue("WorkspacePath") | Should be "$TestDrive"
			Get-InspectionValue("ActionPath") | Should be "$(Join-Path $TestDrive "Continuous")"
			Get-InspectionValue("PackagePath") | Should be "$(Join-Path $TestDrive "packages")"
			Get-InspectionValue("ModulePath") | Should be "$(Join-Path $TestDrive ".modules")"
			Get-InspectionValue("NuGetFilePath") | Should be "$(Join-Path $TestDrive ".nuget\nuget.exe")"
		}

		It "passes specific arguments to action" {
			Get-InspectionValue("DefaultTextParameter") | Should be "Default Text Value"
			Get-InspectionValue("TextParameter") | Should be "Text Value"
			Get-InspectionValue("SwitchParameter") | Should be $true
		}
	}

	Context "exiting on error was forced with error" {

		powershell (Join-Path $TestDrive "Invoke-Continuous.ps1") Exception -ExitOnError -Verbose
		
		It "exits PowerShell process with non zero exit code" {
			$LASTEXITCODE | Should Not Be 0
		}
	}

	Context "exiting on error was forced with error" {

		powershell (Join-Path $TestDrive "Invoke-Continuous.ps1") Nothing -ExitOnError -Verbose

		It "exits PowerShell process with zero exit code" {
			$LASTEXITCODE | Should Be 0
		}
	}
}
