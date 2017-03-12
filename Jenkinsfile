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
                dir('fw/working') {
                    sh 'source /opt/Xilinx/Vivado/2016.4/settings64.sh; vivado -mode tcl -source ../../scripts/build_fw.tcl -notrace'
                }
            }
        }
        stage('Deploy') {
            steps {
                dir('fw/working') {
                    sh 'source /opt/Xilinx/Vivado/2016.4/settings64.sh; vivado -mode tcl -source ../../scripts/program_nexys.tcl -notrace'
                }
            }
        }
        stage('System_Test') {
            steps {
                dir('test/pytest') {
                    sh 'pytest --junitxml=report.xml --html=report.html -v'
                }
                junit 'test/pytest/*.xml'
            }
        }
    }
}