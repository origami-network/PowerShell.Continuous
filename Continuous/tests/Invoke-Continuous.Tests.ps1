$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Bootstraps workspace" {

	Context "clean environment" {
		It "downloads NuGet.exe" {
			
		}

		It "restores NuGet packages" {
			
		}

		It "creates PowerShell modules form NuGet packages" {
			
		}

		It "extends PowerShell modules path with workspace" {
			
		}

		It "extends PowerShell modules path witch modules from NuGet packages" {
			
		}
	}

	Context "cleaning environment was forced" {
		It "deletes NuGet packages folder" {
			
		}

		It "deletes created PowerShell modules folder" {
			
		}
	}

	Context "nuget.exe already exists" {
		It "use existing nuget.exe" {
			
		}
	}

	Context "finished successfully" {
		It "removes workspace from PowerShell modules path" {
			
		}

		It "removes modules from NuGet packages from PowerShell modules path" {
			
		}
	}

	Context "finished with error" {
		It "removes workspace from PowerShell modules path" {
			
		}

		It "removes modules from NuGet packages from PowerShell modules path" {
			
		}
	}
}

Describe "Executes action" {
	Context "action has arguments" {
		It "passes default script arguments to action" {
			
		}

		It "passes specific arguments to action" {

		}
	}

	Context "exiting on error was forced" {
		It "exits PowerShell process with non zeros status code" {
			
		}
	}
}
