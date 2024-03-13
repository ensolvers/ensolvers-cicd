#!/bin/bash
set -eu

BASEDIR=$(dirname "$0")
APP_PATH=("$1")
AWS_ENV_CONFIGURATION=${2-""}
BUILD_PATH=${3-"build"}
TIME_DEPLOY=$(date +%s)

#load utils
source "$BASEDIR/utils/slack_notification.sh"
source "$BASEDIR/utils/error_handler_slack_message.sh"

if [ "$AWS_ENV_CONFIGURATION" != "--ignore-aws-vars" ]; then
  $BASEDIR/utils/check-aws-env.sh
fi

# Checks required vars
: $ENVIRONMENT_FILE $S3_BUCKET $CLOUDFRONT_DISTRIBUTION_ID

if [ -z "$TAG" ]; then
  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC][FRONTEND] - Deploying \`${BRANCH}\`"
else
  slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC][FRONTEND] - Deploying from tag \`${TAG}\`"
fi

slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC][FRONTEND] - Building for \`${APP_PATH}\`"

echo "[$(date)] Building app..."
cd "$APP_PATH"
rm -rf $BUILD_PATH
cp src/environment.json src/environment-backup.json
cp src/$ENVIRONMENT_FILE src/environment.json
cp src/$ENVIRONMENT_FILE src/external/fox-typescript/environment.json
echo "{\"version\": \"$(date '+%Y-%m-%d %H:%M:%S')\"}" > public/version.json # TODO to be replaced by automatic tagging script
yarn install
yarn build
cp src/environment-backup.json src/environment.json
rm -rf src/environment-backup.json public/version.json

echo "[$(date)] Uploading file to S3"
aws s3 sync $BUILD_PATH s3://$S3_BUCKET/ --acl public-read

echo "[$(date)] Triggering CF distribution invalidation"
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"

TIME_FINAL=`expr $(date +%s) - $TIME_DEPLOY`
slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC][FRONTEND] - Deploy Finished - Took $((TIME_FINAL /60/60)) hours, $(((TIME_FINAL /60) % 60)) minutes, $((TIME_FINAL % 60)) seconds."