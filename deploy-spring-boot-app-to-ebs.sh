#!/bin/bash
set -eu

BASEDIR=$(dirname "$0")
MODULE_LIST=("$1")
AWS_ENV_CONFIGURATION=${2-""}

if [ "$AWS_ENV_CONFIGURATION" != "-ignore-aws-vars" ]; then
  $BASEDIR/utils/check-aws-env.sh
fi

# gets the modules
SIZE=${#MODULE_LIST[*]}

for (( i=0; i<SIZE; i++ ))
  do

  MODULE_NAME=${MODULE_LIST[i]}

  echo "Building module ${MODULE_NAME}"
  echo "IMPORTANT: remember that in default config, the branch that you are deploying from is linked to the environment to which the app will be deployed"
  echo "YOUR BRANCH IS: [$(git branch --show-current)]"

  echo "[$(date)] Building app..."
  mvn clean install spring-boot:repackage -DskipTests -pl :$MODULE_NAME -am

  echo "[$(date)] Deploying to Elastic Beanstalk..."
  cd "modules/$MODULE_NAME"
  eb deploy --staged --verbose

  cd -
done
