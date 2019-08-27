pipeline {
    agent any
    tools {nodejs "node" }
    environment {
        registry = "XXXXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/tweety:latest" // repace XX.. with AWS account id
        NAME = "tweety"
        taskName = "tweety"
        cluster = "myapp-prod-tweety-ecs-cluster"
        serviceName = "tweety"
        taskFamily = "tweety"
        TAG = "latest"
        elogin = ""
    }
    stages {

        stage('Npm install') {
            steps {
                echo 'Install..'
                sh 'npm install'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
    
        stage('Build docker image') {
            steps {
                echo 'Build docker image...'
                sh "docker build -t tweety ."
                echo 'Tag image...'
                sh "docker tag tweety:latest ${registry}"
            }
        }
        
        stage("ECR Login") {
            steps {
                withAWS(credentials:'aws-credentials', region: 'us-east-1') {
                    script {
                        elogin = ecrLogin()
                        sh "${elogin}"
                    }
                }
            }
        }
        
        stage('ECR Push') {
            steps {
                echo 'Pushing....'
                sh "docker push ${registry}"
            }
        }

        // 1. get task revision
        // 1.a. increment task revision number
        // 1.b. generate task definition (this step can be skiped)
        // 2 get task arn
        // 3. update service: scale down service to 0 [for dev, needs improvement for prod]
        // 4. stop task
        // 5. register task (Note: the image tag is `latest` and by default task revision will incremented by 1)
        // 6. update service with the new task  

        stage('Deploy') {
            steps {
                withAWS(credentials:'aws-credentials', region: 'us-east-1') {
                    script {
                        def currentTaskRevision = sh(
                            returnStdout: true,
                            script: "aws ecs describe-task-definition  --task-definition ${taskName} | egrep 'revision' |  tr ',' ' '   | awk '{print \$2}'"
                        ).trim()
                        echo "current revision: ${currentTaskRevision}"

                        // next task revision number
                        def newTaskRevision = sh(
                            returnStdout: true,
                            script: "expr ${currentTaskRevision} + 1"
                        ).trim()
                        echo "next revision: ${newTaskRevision}"

                        // generate task definition file (although its static)
                        sh "sed -e  \"s;%NAME%;${taskName};g\" -e \"s;%TAG%;${TAG};g\" aws/taskdefinition-template.json > \"taskdefinition-${newTaskRevision}.json\""
                        
                        // Task definition file
                        def taskDefile = sh(
                            returnStdout: true,
                            script: "echo file://taskdefinition-${newTaskRevision}.json"
                        )

                        // get current task arn
                        def currentTaskArn = sh(
                            returnStdout: true,
                            script: "aws ecs list-tasks  --cluster ${cluster} --family ${taskFamily} --output text | egrep 'TASKARNS' | awk '{print \$2}'"
                        ).trim()
                        echo "current Task arn is ${currentTaskArn}"

                        // if current task definition exists
                        if (currentTaskRevision) {
                            echo "scale down the service ${serviceName} ${taskName}:${currentTaskRevision} to 0"
                            script: "aws ecs update-service  --cluster ${cluster} --service ${serviceName} --task-definition ${taskName}:${currentTaskRevision} --desired-count 0"
                        }

                        // stop task (if exist)
                        if (currentTaskArn) {
                            script: "aws ecs stop-task --cluster ${cluster} --task ${currentTaskArn}"
                        }

                        // register new task definition
                        sh "aws ecs register-task-definition --family ${taskFamily} --cli-input-json ${taskDefile}"

                        // Get the last registered [TaskDefinition#revision]
                        def updatedTaskRevision = sh(
                            returnStdout: true,
                            script: "aws ecs describe-task-definition  --task-definition ${taskName} | egrep 'revision' |  tr ',' ' '   | awk '{print \$2}'"
                        ).trim()

                        // update service to use the new registered task
                        sh "aws ecs update-service  --cluster ${cluster} --service ${serviceName} --task-definition ${taskName}:$updatedTaskRevision --desired-count 1"

                    }
                }
            }
        }
    }
}
