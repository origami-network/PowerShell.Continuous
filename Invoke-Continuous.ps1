#Requires -Version 3.0

[CmdletBinding()]
param(
	[Parameter(Position = 0, Mandatory = $true)]
	[String[]]
	$Action,

	[String]
	$WorkspacePath = (Split-Path $MyInvocation.MyCommand.Path -Parent),
	[String]
	$ActionPath = (Join-Path $WorkspacePath 'Continuous'),
	
	[String]
	$PackagePath = (Join-Path $WorkspacePath 'packages'),
	[String]
	$ModulePath = (Join-Path $WorkspacePath '.modules'),

	[string]
	$NuGetFilePath = (Join-Path $WorkspacePath '.nuget\nuget.exe'),
	[string]
	$NuGetConfigFilePath = (Join-Path $WorkspacePath '.nuget\nuget.config'),
	[version]
	$NuGetFileVersion,

	[switch]
	$Clean,
	[switch]
	$ExitOnError
)

dynamicparam {
	$private:parametersName = $MyInvocation.MyCommand.Parameters.Values |
		% { $_.Name }

	$private:defaultWorkspacePath = $PSBoundParameters['WorkspacePath'], (Split-Path $MyInvocation.MyCommand.Path -Parent) |
		select -First 1
	$private:defaultActionPath = $PSBoundParameters['ActionPath'], (Join-Path $defaultWorkspacePath 'Continuous') |
		select -First 1
	$private:attrubutes = New-Object System.Collections.ObjectModel.Collection[Attribute]
	$attrubutes.Add((New-Object System.Management.Automation.ParameterAttribute))

	$private:parameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

	$PSBoundParameters['Action'] |
		% { Join-Path $defaultActionPath "$($_).action.ps1" -ErrorAction Ignore } |
		? { Test-Path $_ } |
		% { (Get-Command $_).Parameters.Values } |
		? { $parametersName -notcontains $_.Name} |
		? { -not $parameterDictionary.ContainsKey($_.Name) } |
		% { New-Object System.Management.Automation.RuntimeDefinedParameter $_.Name, $_.ParameterType, $attrubutes } |
		% { $parameterDictionary.Add($_.Name, $_) }

	$parameterDictionary
}

begin {
	Write-Verbose (
		"Continuous '$($Action -join ", ")':`n" +
		"`t* Workspace path: $WorkspacePath`n" +
		"`t* Action path: $ActionPath`n" +
		"`t* Package path: $PackagePath`n" +
		"`t* Module path: $ModulePath"
	)

	function private:Find-ModulesInPackage {
		param(
			[String] $PackagePath
		)
		
		Join-Path $PackagePath "*" |
			Get-Item |
			? { $_.Name -imatch "(?<name>.*?)\.(?<version>[0-9]+(\.[0-9]+)*(-.*){0,1})" } |
			% {
				New-Object PSObject -Property @{
					Version = [Version]$matches.version
					VersionLabel = $matches.label
					Name = $matches.Name
					Path = (Join-Path $_.FullName "tools")
					ManifestFilePath = (Join-Path $_.FullName (Join-Path "tools" "$($matches.Name).psd1"))
				}
			} |
			? { Test-Path $_.ManifestFilePath }
	}

	$ErrorActionPreference = 'Stop'
	try {
		if ($Clean) {
			Write-Verbose (
				"Cleaning:`n" +
				"`t* $PackagePath`n" +
				"`t* $ModulePath"
			)

			Write-Progress "Begin" "Clean Package path"
			Remove-Item $PackagePath -Recurse -Force -ErrorAction Ignore
			Write-Progress "Begin" "Clean Module path"
			Remove-Item $ModulePath -Recurse -Force -ErrorAction Ignore
		}

		if (-not (Test-Path $NuGetFilePath)) {
			Write-Progress "Begin" "Download NuGet file."
			New-Item (Split-Path $NuGetFilePath -Parent) -ItemType Directory -Force -ErrorAction Ignore | Out-Null
			$private:NuGetFileUrl = "https://dist.nuget.org/win-x86-commandline/{0}/nuget.exe" -f (
				$NuGetFileVersion, "latest" | select -First 1)
			Invoke-WebRequest $NuGetFileUrl -OutFile $NuGetFilePath -UseBasicParsing	
		}
		Write-Verbose (
			"NuGet file:`n" +
			"`t* version: $((Get-Item $NuGetFilePath).VersionInfo.FileVersion)`n" +
			"`t* path: $NuGetFilePath"
		)
		
		Write-Progress "Begin" "Restore NuGet packages."
		if (Get-Item (Join-Path $WorkspacePath "*.sln")) {
			Write-Verbose "Restore packages from solution"
			if (Test-Path $NuGetConfigFilePath) {
				Write-Verbose "Use '$NuGetConfigFilePath'"
				& $NuGetFilePath restore $WorkspacePath -ConfigFile $NuGetConfigFilePath -verbosity normal | Write-Verbose				
			} else {
				& $NuGetFilePath restore $WorkspacePath -verbosity normal | Write-Verbose
			}
		} elseif (Test-Path (Join-Path $WorkspacePath packages.config)) {
			Write-Verbose "Restore packages from workspace"
			if (Test-Path $NuGetConfigFilePath) {
				Write-Verbose "Use '$NuGetConfigFilePath'"
				& $NuGetFilePath restore (Join-Path $WorkspacePath packages.config) -PackagesDirectory $PackagePath -ConfigFile $NuGetConfigFilePath -verbosity normal | Write-Verbose				
			} else {
				& $NuGetFilePath restore (Join-Path $WorkspacePath packages.config) -PackagesDirectory $PackagePath -verbosity normal | Write-Verbose
			}
		} elseif (Test-Path (Join-Path $ActionPath packages.config)) {
			Write-Verbose "Restore packages from action folder"
			if (Test-Path $NuGetConfigFilePath) {
				Write-Verbose "Use '$NuGetConfigFilePath'"
				& $NuGetFilePath restore (Join-Path $ActionPath packages.config) -PackagesDirectory $PackagePath -ConfigFile $NuGetConfigFilePath -verbosity normal | Write-Verbose
			} else {
				& $NuGetFilePath restore (Join-Path $ActionPath packages.config) -PackagesDirectory $PackagePath -verbosity normal | Write-Verbose
			}
		} else {
			Write-Error "Can't find packages definition for restore."
		}
		if ($LASTEXITCODE) {
			Write-Error "'$_' restore failed with exit code $LASTEXITCODE."
		}

		if (-not (Test-Path $ModulePath)) {
			Write-Progress "Begin" "Create Module path."
			New-Item $ModulePath -Force -ItemType Directory | Out-Null
		}
		Write-Progress "Begin" "Copy modules from packages."
		Find-ModulesInPackage $PackagePath |
			% {
				$targetPath = (Join-Path $ModulePath (Join-Path $_.Name $_.Version))
				if (Test-Path $targetPath) {
					Write-Verbose "Skip '$($_.Name)' version $($_.Version)"
					return
				}
				
				Write-Verbose "Copy '$($_.Name)' version $($_.Version)"
				if ($_.VersionLabel) {
					Write-Warning "Skip version label '$($_.VersionLabel)'."
				}

				Copy-Item $_.Path $targetPath -Recurse -Force
			}

		Write-Progress "Begin" "Extend modules path with Workspace path."
		$env:PSModulePath = ($WorkspacePath, $env:PSModulePath -split ';') -join ";"
		Write-Progress "Begin" "Extend modules path with Module path."
		$env:PSModulePath = ($ModulePath, $env:PSModulePath -split ';') -join ";"
	} catch {
		$_ | Out-String | Write-Error -ErrorAction Continue
		$private:beginException = $_
	}
}

process {
	$private:allParameters = @{}
	$PSBoundParameters.Keys |
		% { $allParameters.Add($_, $PSBoundParameters[$_]) }
	$MyInvocation.MyCommand.Parameters.Values |
		? { -not ($_.IsDynamic -or $allParameters.ContainsKey($_.Name)) } |
		% { Get-Variable $_.Name -ErrorAction Ignore } |
		% { $allParameters.Add($_.Name, $_.Value) }

	$Action |
		% {
			if ($processException -or $beginException) {
				Write-Verbose "Continuous action '$($_)' skipped."
			} else {
				$_
			}
		} |
		% {
			try {
				Write-Progress "Process" "Action '$($_)'."
				
				$private:actionFilePath = Join-Path $ActionPath "$($_).action.ps1"
				$private:parameters = @{}
				(Get-Command $actionFilePath).Parameters.Values |
					? { $allParameters.ContainsKey($_.Name) } |
					% { $parameters.Add($_.Name, $allParameters[$_.Name]) } 
				
				(& $actionFilePath @parameters )
			} catch {
				$_ | Out-String | Write-Error -ErrorAction Continue
				$private:processException = $_
			}
		}
}

end
{
	Write-Progress "End" "Remove Module path from modules path."
	$env:PSModulePath = ( ($env:PSModulePath -split ';') | ? { $_ -ne $ModulePath } ) -join ";"
	Write-Progress "End" "Remove Workspace path from modules path."
	$env:PSModulePath = ( ($env:PSModulePath -split ';') | ? { $_ -ne $WorkspacePath } ) -join ";"

	Write-Progress "End" -Completed
	if ($beginException -or $processException) {
		if ($ExitOnError) {
			[Environment]::Exit(-1)
		}
	}
}
