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
		"$_.txt" | 
			% {
				$Project.ProjectItems.Item($_).Remove()
				Remove-Item (Join-Path $projectPath $_) -Force
			}
		$_
	} |
    % { $Project.ProjectItems.AddFromFile((Join-Path $solutionPath $_)) } |
	% { $_.Properties.Item("BuildAction").Value = [int]2 }
