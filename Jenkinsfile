pipeline {
    agent any

    stages {
        stage('Compile') {
            steps {
                dir('fw/working') {
                    sh 'ghdl -i --work=IO ../src/IO/*.vhd'
                    sh 'ghdl -i --work=NEXYS ../src/NEXYS/*.vhd'
                    sh 'ghdl -i --work=UART ../src/UART/*.vhd'
                    sh 'ghdl -i --work=xil_defaultlib ../src/xil_defaultlib/*.vhd'
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