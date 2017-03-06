#!groovy

stage ("Integration") {
    node {
        checkout([
           $class: 'GitSCM',
           branches: [[name: '**']],
           doGenerateSubmoduleConfigurations: false,
           extensions: [[$class: 'CleanBeforeCheckout']],
           submoduleCfg: [],
           userRemoteConfigs: [[url: 'https://github.com/origami-network/PowerShell.Continuous.git']]
        ])

		try {
			bat 'powershell .\\Invoke-Continuous.ps1 Integration -ExitOnError'
		} finally {
 			step([
				$class: 'NUnitPublisher',
				testResultsPattern: '.artifacts/Reports/**/*.NUnit.xml',
				debug: false,
				keepJUnitReports: false,
				skipJUnitArchiver: false,
				failIfNoResults: false
			])
		}

        stash includes: '.artifacts/Packages/**', name: 'packages'
    }
}

stage ("Delivery") {
    input 'Publish on nuget.org?'
    node {
        withCredentials([[$class: 'StringBinding', credentialsId: 'nuget.org - push', variable: 'APIKEY']]) {
			bat 'powershell .\\Invoke-Continuous.ps1 Delivery -NuGetApiKey ${env.APIKEY} -ExitOnError'            
        }
    }
}
