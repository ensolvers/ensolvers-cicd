#!/bin/bash

# If you don't use sonar or jacoco, just send the first three parameters. The script will ignore the sonar/jacoco side.

# When you use this script on CodeBuild, make sure that the Timeout is one hour just in case that the script can work
# the entire cycle. If you don't put enough timeout, it will cancel and fail the build.

BASEDIR=$(dirname "$0")
APPLICATION_PROPERTIES_PATH=$1
REPORTS_DIR=$2
PACKAGE_NAME=$3
SONAR_TOKEN=$4
SONAR_PROJECT_KEY=$5

#load utils
source "$BASEDIR/utils/slack_notification.sh"

if [ -z "$APPLICATION_PROPERTIES_PATH" ]
then
  slack_notification "[TEST-RUNNER] :alert-red: Parameter not defined: APPLICATION_PROPERTIES_PATH :alert-red:"
  exit 1
fi

if [ -z "$REPORTS_DIR" ]
then
  slack_notification "[TEST-RUNNER] :alert-red: Parameter not defined: REPORTS_DIR :alert-red:"
  exit 1
fi

if [ -z "$PACKAGE_NAME" ]
then
  slack_notification "[TEST-RUNNER] :alert-red: Parameter not defined: PACKAGE_NAME :alert-red:"
  exit 1
fi

slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - Running Tests..."

#set testcontainers
echo "Configuring test containers"
printf "\ntestcontainers.db.engine=\${TEST_CONTAINERS_DB_ENGINE:mysql}" >> $APPLICATION_PROPERTIES_PATH
printf "\ntestcontainers.redis.enabled=\${TEST_CONTAINERS_REDIS_ENABLED:true}" >> $APPLICATION_PROPERTIES_PATH
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]
then
  slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - :alert-red: Can't run tests: error configuring application.properties :alert-red:"
  exit 1
fi

# Run tests. Make sure to let the maven test failure *after* the verify instruction on the command.
echo "Running tests"
if [[ $# -eq 5 ]] ; then
  mvn clean org.jacoco:jacoco-maven-plugin:$jacoco_version:prepare-agent verify -Dmaven.test.failure.ignore=true org.jacoco:jacoco-maven-plugin:$jacoco_version:report
elif
  mvn test -Dtest="$PACKAGE_NAME".**.* -DfailIfNoTests=false
fi
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]
then
  #search for failing tests files
  results=""
  for file in $REPORTS_DIR/*.txt
  do
    f="$(($(grep -c 'FAILURE!' "$file")))"
    e="$(($(grep -c 'ERROR!' "$file")))"
    if [[ $f -gt 0 ]] || [[ $e -gt 0 ]]
    then
      package=$(basename "$file" .txt)
      name=${package//*.}
      results+="> *$name* | Failures: $f | Errors: $e\n\n"
    fi
  done

  slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - <!channel> :alert-red: Tests are failing  :x:  :alert-red:\n\n$results"
  exit 1
fi

# Generating reports for Sonar. Exclude the submodules to avoid pulling unneeded reports from core or similar.
# Disable the scm exclusion to make sure that all the files are pulled
if [[ $# -eq 5 ]] ; then
  mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN -Dsonar.projectKey=$SONAR_PROJECT_KEY -DsonarExclusions=submodules/** -Dsonar.scm.exclusions.disabled=true
fi
slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - Report for Tests created! :green-check-mark:"

slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - All tests are passing! :green-check-mark:"