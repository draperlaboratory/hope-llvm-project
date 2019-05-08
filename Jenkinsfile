@Library('hope-jenkins-library')_

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                buildProject([
                    project: "llvm"
                ])
            }
        }
        stage('Rebuild newlib') {
            steps {
                build job: "hope-riscv-newlib"
            }
        }
        stage('Run tests') {
            steps {
                build job: "hope-policies"
            }
        }
    }
}
