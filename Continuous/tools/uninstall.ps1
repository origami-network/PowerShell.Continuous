param (
    $InstallPath,
    $ToolsPath,
    $Package,
    $Project
)

$projectPath = Split-Path -Parent $Project.FullName
$solutionPath = Split-Path -Parent $projectPath

"Invoke-Continuous.ps1" |
    % {
        $Project.ProjectItems.Item($_).Remove()
    }
	# TODO: check that it is last project with this item and remove file if so
