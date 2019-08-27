#!/bin/bash

NAME=tweety
taskName=tweety
cluster=tweety-ecs
serviceName=tweety
taskFamily=tweety
TAG=latest

# get the current task revision
currentTaskRevision=`aws ecs describe-task-definition  --task-definition ${taskName} | egrep 'revision' |  tr ',' ' '   | awk '{print $2}'`
echo "current revision is $currentTaskRevision"

# new task revision TODO: can use commit as tag
newTaskRevision=`expr $currentTaskRevision + 1`
echo $newTaskRevision

# generate task definition file (although its static)
sed -e  "s;%NAME%;${taskName};g" -e "s;%TAG%;${TAG};g" aws/taskdefinition-template.json > "taskdefinition-${newTaskRevision}.json"
taskDefile="file://taskdefinition-${newTaskRevision}.json"

# get current task arn
currentTaskArn=`aws ecs list-tasks  --cluster ${cluster} --family ${taskFamily} --output text | egrep 'TASKARNS' | awk '{print $2}'`
echo "current Task arn is $currentTaskArn"

# if current task definition exists
if [ -n "$currentTaskRevision" ]; then
    echo "scale down the service ${serviceName} ${taskNamek}${currentTaskRevision} to 0"
    aws ecs update-service  --cluster ${cluster} --service ${serviceName} --task-definition ${taskName}:${currentTaskRevision} --desired-count 0
fi

# stop task (if exist)
if [ -n "$currentTaskArn" ]; then
    aws ecs stop-task --cluster ${cluster} --task ${currentTaskArn}
fi

# register new task definition
aws ecs register-task-definition --family ${taskFamily} --cli-input-json $taskDefile

# Get the last registered [TaskDefinition#revision]
newTaskRevision=`aws ecs describe-task-definition  --task-definition ${taskName} | egrep 'revision' |  tr ',' ' '   | awk '{print $2}'`

# update service to use the new registered task
aws ecs update-service  --cluster ${cluster} --service ${serviceName} --task-definition ${taskName}:$newTaskRevision --desired-count 1  
