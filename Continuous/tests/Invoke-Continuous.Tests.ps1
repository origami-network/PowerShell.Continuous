param (
	[string]
	$Here = (Split-Path -Parent $MyInvocation.MyCommand.Path),
	
	[string]
	$InvokeContinuousFilePath = (Join-Path ($Here | Split-Path -Parent | Split-Path -Parent) "Invoke-Continuous.ps1")
)


Describe "Bootstraps workspace" {
	
	Copy-Item $InvokeContinuousFilePath $TestDrive

	Context "clean environment" {
		# TODO: prepare other artifacts
		# TODO: Use mock method to get values from actions script
		# TODO: Execute script an cache error

		It "downloads NuGet.exe" {
			$nugetFilePath = Join-Path $TestDrive ".nuget\nuget.exe"

			Test-Path $nugetFilePath | Should be $true
		}

		It "restores NuGet packages" {
			$packagePath = Join-Path $TestDrive "packages"
			$packageMeasure = Get-ChildItem $packagePath | measure

			Test-Path $packagePath | Should be $true
			Test-Path $packageMeasure.Count | Should be 2
		}

		It "creates PowerShell modules form NuGet packages" {
			$modulePath = Join-Path $TestDrive ".modules"
			$moduleMeasure = Get-ChildItem $packagePath | measure

			Test-Path $modulePath | Should be $true
			Test-Path $moduleMeasure.Count | Should be 1
		}

		It "extends PowerShell modules path with workspace" {
			$modulePath = $TestDrive
			$modulePaths = $actionPSModulePath -split ";"

			$modulePaths -contains $modulePath | Should be $true 
		}

		It "extends PowerShell modules path witch modules from NuGet packages" {
			$modulePath = Join-Path $TestDrive ".modules" 
			$modulesPaths = $actionPSModulePath -split ";" 

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
		
		$fakePackageContentFile = Join-Path $TestDrive "packages\Some.Package-1.0.0\Content\Fake.txt"
		New-Item  (Split-Path $fakePackageContentFile -Parent) -ItemType Directory -Force |
			Out-Null
		Set-Content $fakePackageContentFile -Value ""

		$fakeModuleManifestFilePath = Join-Path $TestDrive ".modules\Fake.Module\1.0.0\Fake.Module.psd1"
		New-Item  (Split-Path $fakeModuleManifestFilePath -Parent) -ItemType Directory -Force |
			Out-Null
		Set-Content $fakeModuleManifestFilePath -Value ""

		# TODO: prepare other artifacts	
		# TODO: Execute script an cache error

		It "deletes NuGet packages folder" {
			for (
				$filePath = $fakePackageContentFile
				$filePath -ne $TestDrive
				$filePath = Split-Path $filePath -Parent
			) {
				Test-Path $filePath | Should be  $false
			}
		}

		It "deletes created PowerShell modules folder" {
			for (
				$filePath = $fakeModuleManifestFilePath
				$filePath -ne $TestDrive
				$filePath = Split-Path $filePath -Parent
			) {
				Test-Path $filePath | Should be  $false
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

	Copy-Item $InvokeContinuousFilePath $TestDrive

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
