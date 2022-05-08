#!/bin/bash
set -eu
BASEDIR=$(dirname "$0")

$BASEDIR/utils/check-aws-env.sh

# Checks required vars
: $REACT_APP_PATH $ENVIRONMENT_FILE $S3_BUCKET $CLOUDFRONT_DISTRIBUTION_ID

echo "[$(date)] Building app..."
cd $REACT_APP_PATH
rm -rf build
cp src/environment.json src/environment-backup.json
cp src/$ENVIRONMENT_FILE src/environment.json
echo "{\"version\": \"$(date '+%Y-%m-%d %H:%M:%S')\"}" > public/version.json # TODO to be replaced by automatic tagging script
yarn install
yarn build
cp src/environment-backup.json src/environment.json
rm -rf src/environment-backup.json public/version

echo "[$(date)] Uploading file to S3"
aws s3 sync build s3://$S3_BUCKET/ --acl public-read

echo "[$(date)] Triggering CF distribution invalidation"
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
