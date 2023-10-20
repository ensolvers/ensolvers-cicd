#!/bin/bash
echo "Ensolvers Runner v0.1"

stop_java() {
    echo "Received signal. Stopping Java application..."
    kill -TERM $java_pid
    kill -TERM $test_pid
    wait $java_pid
    exit $?
}

trap 'stop_java' SIGINT SIGTERM

/test.sh &
test_pid=$!

if [[ ! -z $JAR_FILE_S3_URL ]]; then
    echo "Fetching [$JAR_FILE_S3_URL]"
    aws s3 cp $JAR_FILE_S3_URL /app.jar
    
    echo "Running jar..."
    if [[ ! -z $NEW_RELIC_LICENSE_KEY ]]; then
        NEW_RELIC_VERSION="$(java -jar /newrelic.jar -v)"
        echo "Running with New Relic version $NEW_RELIC_VERSION, license_key: [$NEW_RELIC_LICENSE_KEY], app_name: [$NEW_RELIC_APP_NAME]"
        java -javaagent:/newrelic.jar -Dnewrelic.config.license_key=$NEW_RELIC_LICENSE_KEY -Dnewrelic.config.app_name=$NEW_RELIC_APP_NAME $JVM_PARAMS -jar /app.jar
        java_pid=$!
    else
        java $JVM_PARAMS -jar /app.jar &
        java_pid=$!
    fi
    wait $java_pid
fi 