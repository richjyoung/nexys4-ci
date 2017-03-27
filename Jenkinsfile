pipeline {
    agent any

    stages {
        stage('Syntax Check') {
            steps {
                dir('fw/working') {
                    sh 'for i in ../src/*; do if [ -d "$i" ]; then ghdl -i --work=$(basename $i) $i/*.vhd; fi; done;'
                }
            }
        }
        stage('Unit Test') {
            steps {
                dir('test/vunit') {
                    sh 'python3 run.py --gtkwave-fmt ghw --no-color -x unit_test.xml'
                }
                junit 'test/vunit/*.xml'
            }
        }
        stage('Synthesis & PAR') {
            steps {
                dir('fw/working') {
                    sh 'source /opt/Xilinx/Vivado/2016.4/settings64.sh; vivado -mode batch -source ../../scripts/build_fw.tcl -notrace'
                }
                archiveArtifacts artifacts: 'fw/working/*.txt'
            }
        }
        stage('Deploy') {
            steps {
                dir('fw/working') {
                    sh 'source /opt/Xilinx/Vivado/2016.4/settings64.sh; vivado -mode batch -source ../../scripts/program_nexys.tcl -notrace'
                }
            }
        }
        stage('System Test') {
            steps {
                dir('test/pytest') {
                    sh 'pytest --junitxml=report.xml --html=report.html -v'
                }
                junit 'test/pytest/*.xml'
            }
        }
    }
}