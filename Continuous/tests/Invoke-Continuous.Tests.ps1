$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Bootstrap Environment" {

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

	Context "action has arguments" {
		It "passes default script arguments to action" {
			
		}

		It "passes specific arguments to action" {

		}
	}

	Context "finished successfully" {
		It "removes workspace from PowerShell modules path" {
			
		}

		It "removes modules from NuGet packages from PowerShell modules path" {
			
		}
	}

	Context "finished with error" {
		It "remove workspace from PowerShell modules path" {
			
		}

		It "remove modules from NuGet packages from PowerShell modules path" {
			
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

	Context "exiting on error was forced" {
		It "exit PowerShell process with non zeros status code" {
			
		}
	}
}
