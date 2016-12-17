# Introduction

Bootstrap script to help execute continuous actions using PowerShell and NuGet packages.

It was created in order to simplify building continuous pipelines for and in Visual Studio projects,
using the power of scripting language.

## Usage

The NuGet package is prepared for easy install and use in Visual Studio.

1. Create new Solution in Visual Studio or use the current one.
2. Create new Class Library project with name `Continuous`.
2. Install `Origami.PowerShell.Continuous` package using visual tool or Package Manager Console:
	```batch
	PM> Install-Package -Id Origami.PowerShell.Continuous -ProjectName Continuous
	```
3. Create new file `Example.action.ps1` in root folder of `Continuous` project with the required parameters and steps.
4. Open PowerShell command prompt.
5. Change current directory to Solution folder.
7. Invoke continuous action:
	```batch
	PS> ./Invoke-Continuous Example
	```

### Action file

> TODO: describe parameters

### Parameters

> TODO: describe parameters

### NuGet package with PowerShell module

> TODO: describe how it works

### Continuous Integration/Deployment

> TODO: describe how to use it

## How it works

> TODO: Describe the bootstrap process

## Contributing 

> TODO: Describe how to contribute to project

### Road Map

> TODO: Describe what eventually need to be done to make the tool even better
