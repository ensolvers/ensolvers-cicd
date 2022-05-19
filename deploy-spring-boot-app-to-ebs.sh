#!/bin/bash
set -eu

BASEDIR=$(dirname "$0")
APP_DIR=$1

$BASEDIR/utils/check-aws-env.sh

if [ -n "$APP_DIR" ]
then
  cd $APP_DIR
fi

echo "IMPORTANT: remember that in default config, the branch that you are deploying from is linked to the environment to which the app will be deployed"
echo "YOUR BRANCH IS: [$(git branch --show-current)]"

echo "[$(date)] Building app..."
mvn clean install spring-boot:repackage -DskipTests

echo "[$(date)] Deploying to Elastic Beanstalk..."
eb deploy --staged --verbose 
