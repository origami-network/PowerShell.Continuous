#!groovy

stage ("Build") {
    node {
        checkout([
           $class: 'GitSCM',
           branches: [[name: '**']],
           doGenerateSubmoduleConfigurations: false,
           extensions: [[$class: 'CleanBeforeCheckout']],
           submoduleCfg: [],
           userRemoteConfigs: [[url: 'https://github.com/origami-network/PowerShell.Continuous.git']]
        ])
        bat 'powershell .\\Invoke-Continuous.ps1 Integration -ExitOnError'
        bat 'set'
        stash includes: '.artifacts/Packages/**', name: 'packages'
    }
}

stage ("Release") {
    input 'Publish on nuget.org?'
    node {
        withCredentials([[$class: 'StringBinding', credentialsId: 'secret', variable: 'TOKEN']]) {
            bat 'echo %TOKEN%'
        }
    }
}
