// this Jenkinsfile is for Eureka Microservice

pipeline {
    agent {
        label "jenkins-slave"
    }
    tools {
        maven "maven-3.8.8"
        jdk "jdk-17"
    }
    environment {
        APPLICATION_NAME = "Eureka"
        SONAR_URL = 'http://34.82.211.18:9000'
        SONAR_TOKEN = credentials('sonar_creds')
    }
    stages {
        stage('Build') {
            steps {
                echo "Building ${env.APPLICATION_NAME} Application"
                sh "mvn clean package -DskipTests=true"
                archiveArtifacts artifacts: 'target/*.jar'
            }
        }
        stage ('Unit Tests') {
            steps {
                echo "Performing the Unit Tests for ${env.APPLICATION_NAME} Application"
                sh "mvn test"
            }
            post {
                always {
                    junit "target/surefire-reports/*.xml"
                    jacoco execPattern: "target/jacoco.exec"
                }
            }
        }
        stage ('Sonar Scan') {
            steps {
                echo "Starting sonar scans with Quality Gates for ${env.APPLICATION_NAME} Application"
                withSonarQubeEnv('SonarQube') {
                    sh """
                    mvn sonar:sonar \
                        -Dsonar.projectKey=eureka-ms \
                        -Dsonar.host.url=${env.SONAR_URL} \
                        -Dsonar.login=${env.SONAR_TOKEN}
                    """
                }
                timeout (time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                } 
            }
        }
    }
}
