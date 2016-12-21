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

The only mandatory parameter is:
 
 - __`Action`__ - that correspond to the action file.
   The name can be omitted if it will be passed as the first parameter.

   > It is also possible to pass the list of action names. They will by executed one by one.
   > If an error occurs in one action the rest onces will be skipped.

The fallowing switches can be used to control execution flow:

 - __`Clean`__ - forces to clean the package and module path on the early beginning of the invocation.
   Can be useful in order to remove some old packages or modules and refresh the dependencies.
 - __`ExitOnError`__ - forces to exit PowerShell process with status -1 if any error occurred during invocation.
   It is useful for various CI/CD tools to indicate that something bad happed during invocation.

   > Please be aware that if you enable this switch in command line, without starting new PowerShell process,
   > the console window will be closed in case of errors.

If it could be useful fallowing parameters can be overwritten from its default values:

 - __`WorkspacePath`__ - base path of the Visual Studio solution.
   By default the folder where Invoke-Continuous script is located.

   This folder will be also added to the 'PSModulePath' in order to extend places where
   the PowerShell modules could be found.

 - __`ActionPath`__ - path were the action files should be located.
   By default the `Continuous` sub folder of the `WorkspacePath`. 

 - __`PackagePath`__ - path were NuGet packages will be restored.
   By default the `packages` sub folder of the `WorkspacePath`. 
 
 - __`ModulePath`__ - path were PowerShell modules will be restored
   from restored NuGet packages. 
   By default the `.modules` sub folder of the `WorkspacePath`.

   This folder will be also added to the 'PSModulePath' in order to extend places where
   the PowerShell modules could be found.

 - __`NuGetFilePath`__ - the file location of the `NuGet.exe` console tool.
   By default it point to `NuGet.exe` inside `.nuget` sub folder of the `WorkspacePath`

   > If `NuGet.exe` can be found, in the location, it will be downloaded from
   > https://dist.nuget.org/win-x86-commandline.

 - __`NuGetFileVersion`__ - allow to chose specific version of `NuGet.exe` to download.
   By default it do not have any value, witch will stands for latest available stable version.

In addition all standard cmdlet parameters can be passed. In advance `Verbose` to extend
console output from the invocation.

All this parameters can be populated to the action script.
This is done by defining parameters of action that match type and name of those mentioned earlier.

In addition, dynamic parameters can be passed to the invocation.
They will be populated to the action script if they will match by name.

> Additional parameters need to be specified by name.


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

If you want to report and issue or any idea, fell free to use [issue list](https://github.com/origami-network/PowerShell.Continuous/issues).
This also include the point from Road Map if you do not find it yet the item there. I will use it to prioritize work.

If you want to introduce some changes in the code, You can fork the repository and submit it through pull request.


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