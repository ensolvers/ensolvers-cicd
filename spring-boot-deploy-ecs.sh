#!/bin/bash
set -e

BASEDIR=$(dirname "$0")

#load utils
echo "sourcing slack_notification.sh"
source "$BASEDIR/utils/slack_notification.sh"
echo "sourcing error_handler_slack_message.sh"
source "$BASEDIR/utils/error_handler_slack_message.sh"


TIME_DEPLOY=$(date +%s)
LIST_APPS=("$1")
#Comma separated modules to be tested
MODULES_TO_TEST=("$2")

echo "Importing variables from $ROOT_DIR/deploy/${ENV^^}-Var-Build.sh"
build_script="$ROOT_DIR/deploy/${ENV^^}-Var-Build.sh"
source "$build_script"

if [ -z "$TAG" ]; then
  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploying ${BRANCH}"
else
  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploying from tag ${TAG}"
fi

echo "WEBHOOK SLACK"
echo $SLACK_WEBHOOK_URL
slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Building for ${LIST_APPS[*]}"

CLEAN_CMD="clean"
if [ "$SKIP_CLEAN_REPACKAGE" = "true" ]; then
  CLEAN_CMD=""
fi

if [ -z "$MODULES_TO_TEST" ]; then
  mvn $CLEAN_CMD package spring-boot:repackage -DskipTests
else
  mvn $CLEAN_CMD package spring-boot:repackage -DskipTests=false -pl $MODULES_TO_TEST
fi

ERROR_CODE=$?

if [ "$ERROR_CODE" -gt 0 ]
then
  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Building Failed - Error Code: $ERROR_CODE"
  { exit 1; }
fi

# gets the modules
SIZE=${#LIST_APPS[*]}

for (( i=0; i<SIZE; i++ ))
  do

  export APP_NAME=${LIST_APPS[i]}

  echo "Importing variables from ./deploy/${ENV^^}-${APP_NAME}.sh"
  REQUIRED_BUILD_VARS="./deploy/${ENV^^}-${APP_NAME}.sh"
  source "$REQUIRED_BUILD_VARS"

  export JAR_NAME="${APP_NAME}-$(date +%Y%m%d%H%S).jar"
  export JAR_FILE_S3_URL="s3://$S3_BUCKET_NAME/$APP_NAME/$JAR_NAME"


  export MODULE_NAME=${MODULE_NAME:-$APP_NAME}
  # --------------- Build and Upload to s3 ---------------
  cd $ROOT_DIR/modules/$MODULE_NAME

  echo "Building and uploading jar file:
    S3_BUCKET_NAME=$S3_BUCKET_NAME
    APP_NAME=$APP_NAME"

  # NOTE: maven wrapper is assumed
  # build and normalize jar name - assuming only one output jar

  TARGET_ORIGINAL=target/*.original
  if [ -f "$TARGET_ORIGINAL" ]; then
    rm $TARGET_ORIGINAL
  fi
  mv target/*.jar target/"$JAR_NAME"

  echo "Uploading $JAR_NAME to $JAR_FILE_S3_URL"
  aws s3 cp target/"$JAR_NAME" "$JAR_FILE_S3_URL" --sse aws:kms --sse-kms-key-id "$KEY_ID"

  cd -

  # --------------- Deploy jar ---------------
  echo "Building task definition file"
  dest_taskdef_file=/tmp/task-def-$APP_NAME.json
  envsubst < "$ROOT_DIR"/deploy/task-def.json > "$dest_taskdef_file"

  cat "$dest_taskdef_file"

  echo "Registering new task definition"
  revision=$(aws ecs register-task-definition --family "$CLUSTER_NAME" --network-mode awsvpc --cpu "$VCPU" --memory "$MEMORY" --execution-role-arn $ECS_TASK_EXECUTION_ROLE --task-role-arn $ECS_TASK_EXECUTION_ROLE --requires-compatibilities FARGATE --container-definitions file://"$dest_taskdef_file" --region "$AWS_REGION" | jq -r '.taskDefinition.revision')

  echo "Updating ecs service"
  aws ecs update-service --cluster "$CLUSTER_NAME" --service "$CLUSTER_NAME" --task-definition "$CLUSTER_NAME":"$revision" --region "$AWS_REGION"
done

TIME_FINAL=`expr $(date +%s) - $TIME_DEPLOY`

slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploy Finished - Took $((TIME_FINAL /60/60)) hours, $(((TIME_FINAL /60) % 60)) minutes, $((TIME_FINAL % 60)) seconds."
