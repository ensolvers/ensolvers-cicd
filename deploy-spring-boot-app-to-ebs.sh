#!/bin/bash
set -eu

BASEDIR=$(dirname "$0")
MODULE_LIST=("$1")
AWS_ENV_CONFIGURATION=${2-""}
TIME_DEPLOY=$(date +%s)

#load utils
source "$BASEDIR/utils/slack_notification.sh"
source "$BASEDIR/utils/error_handler.sh"

if [ "$AWS_ENV_CONFIGURATION" != "-ignore-aws-vars" ]; then
  $BASEDIR/utils/check-aws-env.sh
fi

# gets the modules
SIZE=${#MODULE_LIST[*]}

if [ -z "$TAG" ]; then
  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploying \`${BRANCH}\`"
else
  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploying from tag \`${TAG}\`"
fi

slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Building for \`${MODULE_LIST[*]}\`"

for (( i=0; i<SIZE; i++ ))
  do

  MODULE_NAME=${MODULE_LIST[i]}

  echo "Building module ${MODULE_NAME}"
  echo "IMPORTANT: remember that in default config, the branch that you are deploying from is linked to the environment to which the app will be deployed"
  echo "YOUR BRANCH IS: [$(git branch --show-current)]"

  echo "[$(date)] Building app..."
  mvn clean install spring-boot:repackage -DskipTests -pl :$MODULE_NAME -am

  ERROR_CODE=$?

  if [ "$ERROR_CODE" -gt 0 ]
  then
    slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Building Failed - Error Code: $ERROR_CODE"
    { exit 1; }
  fi

  echo "[$(date)] Deploying to Elastic Beanstalk..."
  cd "modules/$MODULE_NAME"
  eb deploy --staged --verbose

  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Module \`$MODULE_NAME\` deployed to EBS"

  cd -
done

TIME_FINAL=`expr $(date +%s) - $TIME_DEPLOY`
slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploy Finished - Took $((TIME_FINAL /60/60)) hours, $(((TIME_FINAL /60) % 60)) minutes, $((TIME_FINAL % 60)) seconds."
