#!/bin/bash
set -e

BASEDIR=$(dirname "$0")

#load utils
source "$BASEDIR/utils/slack_notification.sh"
source "$BASEDIR/utils/error_handler_slack_message.sh"


TIME_DEPLOY=$(date +%s)
LIST_APPS=("$1")

echo "Building task definition file"
dest_taskdef_file=/tmp/task-def-$APP_NAME.json
envsubst < "$ROOT_DIR"/utils/wordpress-task-def.json > "$dest_taskdef_file"

cat "$dest_taskdef_file"

echo "Registering new task definition"
revision=$(aws ecs register-task-definition --family "$CLUSTER_NAME" --network-mode awsvpc --cpu "$VCPU" --memory "$MEMORY" --execution-role-arn "$ECS_TASK_EXECUTION_ROLE" --task-role-arn "$ECS_TASK_EXECUTION_ROLE" --requires-compatibilities FARGATE --cli-input-json file://"$dest_taskdef_file" --region "$AWS_REGION" | jq -r '.taskDefinition.revision')

echo "Updating ecs service"
aws ecs update-service --cluster "$CLUSTER_NAME" --service "$CLUSTER_NAME" --task-definition "$CLUSTER_NAME":"$revision" --region "$AWS_REGION"

TIME_FINAL=`expr $(date +%s) - $TIME_DEPLOY`

slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploy Finished - Took $((TIME_FINAL /60/60)) hours, $(((TIME_FINAL /60) % 60)) minutes, $((TIME_FINAL % 60)) seconds."
