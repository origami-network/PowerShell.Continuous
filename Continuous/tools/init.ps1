param (
    $InstallPath,
    $ToolsPath,
    $Package,
    $Project
)

$projectPath = Split-Path -Parent $Project.FullName
$solutionPath = Split-Path -Parent $projectPath

"Invoke-Continuous.ps1" |
    % { Join-Path $ToolsPath $_ } |
    ? { Test-Path $_ } |
    % { Copy-Item $_ $solutionPath }
