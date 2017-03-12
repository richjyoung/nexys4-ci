pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'echo Build stage'
            }
        }
        stage('Test') {
            steps {
                dir('test/vunit') {
                    sh 'python3 run.py --gtkwave-fmt ghw --no-color -x unit_test.xml'
                }
                junit 'test/vunit/*.xml'
            }
        }
        stage('Implement') {
            steps {
                sh 'echo Implement stage'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo Deploy stage'
            }
        }
        stage('System_Test') {
            steps {
                sh 'echo System_Test stage'
            }
        }
    }
}