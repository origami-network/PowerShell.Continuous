# Introduction

Bootstrap script to help execute continuous actions using PowerShell and NuGet packages.

It was created in order to simplify building continuous pipelines for and in Visual Studio projects,
using the power of scripting language.


## Usage

The NuGet package is prepared for easy install and use in Visual Studio.

 1. Create new Solution in Visual Studio or use the current one.
 2. Create new Class Library project with name `Continuous`.
 3. Install `Origami.PowerShell.Continuous` package using visual tool or Package Manager Console:
	
    ```batch
	PM> Install-Package -Id Origami.PowerShell.Continuous -ProjectName Continuous
	```
  
 5. Create new file `Example.action.ps1` in root folder of `Continuous` project with the required parameters and steps.
 5. Open PowerShell command prompt.
 6. Change current directory to Solution folder.
 7. Invoke continuous action:
	
    ```batch
	PS> ./Invoke-Continuous Example
	```

The Visual Studio Solution folder structure looks as fallow:
 
  - __`.sln`__ solution file
  - __`Invoke-Continuous.ps1`__ script file from Origami.PowerShell.Continuous package
  - __`Continuous`__ project folder with:
    - __`Continuous.csproj`__ project file
    - __`Example.action.ps1`__ action file 
    - __`packages.config`__ file with dependency to `Origami.PowerShell.Continuous` package
    - __`Properties`__ folder with:
      - __`AssemblyInfo.cs`__ file

Optionally it Solution can contain:

  - `.nuget` folder with
      - `NuGet.config` to configure `NuGet.exe` behavior
      - `NuGet.exe` command line tool
  - other Solution project folders


### Action file

One or many PowerShell script files. Placed in `Continuous` project folder with name _`<action name>`_`.action.ps1` where _action name_ will be used as the parameters of `Invoke-Continuous` call.

Each Action file is a standard script or cmdlet file, with or without parameters.

For instance the simple Hello action can look like this:

```powershell
param (
    [string] $Name = "World"
)

Write-Host "Hello, $Name"
```

Calling `PS> ./Invoke-Continuous Hello` in the Solution folder will produce output `Hello, World`.

While `PS> ./Invoke-Continuous Hello -Name "Automation"` will give `Hello Automation` on the console.


### Parameters

> TODO: describe parameters

### NuGet package with PowerShell module

> TODO: describe how it works

### Continuous Integration/Deployment

> TODO: describe how to use it

## How it works

Invoking Action through `Invoke-Continuous` will perform fallowing steps.

 1. Begin
    1. Clean up module and package folder if requested.
    2. Download `NuGet.exe` file from NuGet.org location.
    3. Restore NuGet packages if required.
    4. Extract PowerShell modules from NuGet packages.
    5. Extend PowerShell modules lookup path to Solution folder (workspace) and extracted modules.
 2. Progress
    1. Execute requested action.
 3. End
    1. Restore PowerShell modules lookup path.
    2. Exit process with success (`0`) or error (`-1`) status if requested.

# Contributing 

> TODO: Describe how to contribute to project

## Road Map

The list contains some possible improvements that could be added in the feature. The order of implementation depend on the needs and provided requests.

 - Improve cleaning up on end by removing PowerShell modules imported by the actions.
 - Allow pass values from actions invoked in chain.
 - Auto installing PowerShell modules by utilizing PowerShellGet.
 - Allow to override default values of the parameters.
 - Extended configuration. For instance NuGet version download proxy.
 - Improved logging for various CI/CD tools.
 - Support for other project structures beside Visual Studio Solution.
 - Integration with other editors like Visual Studio Code. 

# License

PowerShell.Continuous is released under the [MIT license](http://www.opensource.org/licenses/MIT).