#!/bin/bash

BASEDIR=$(dirname "$0")
APPLICATION_PROPERTIES_PATH=$1
REPORTS_DIR=$2


if [ -z "$APPLICATION_PROPERTIES_PATH" ]
then
  echo "Env variable not defined: APPLICATION_PROPERTIES_PATH"
  exit 1
fi

if [ -z "$REPORTS_DIR" ]
then
  echo "Env variable not defined: REPORTS_DIR"
  exit 1
fi

#load utils
source "$BASEDIR/utils/slack_notification.sh"

slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - Running Tests..."

#set testcontainers
echo "Configuring test containers"
printf "\ntestcontainers.db.engine=mysql" >> $APPLICATION_PROPERTIES_PATH
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]
then
  slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - :alert-red: Can't run tests: error configuring application.properties :alert-red:"
  exit 1
fi

#compile app
echo "Compiling the app"
mvn compile
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]
then
  slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - :alert-red: Can't run tests: Compilation failed :alert-red:"
  exit 1
fi

#run tests
echo "Running tests"
mvn -B test
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

slack_notification "[TEST-RUNNER] [$(date +"%H:%M:%S") UTC] - All tests are passing! :green-check-mark:"