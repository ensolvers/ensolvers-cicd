#!/bin/bash
echo "Ensolvers Runner v0.2 - Based on amazoncoretto:21"

if [[ ! -z $JAR_FILE_S3_URL ]]; then
    echo "Fetching [$JAR_FILE_S3_URL]"
    aws s3 cp $JAR_FILE_S3_URL /app.jar
    
    echo "Running jar..."
    if [[ ! -z $NEW_RELIC_LICENSE_KEY ]]; then
        NEW_RELIC_VERSION="$(java -jar /opt/newrelic/newrelic.jar -v)"
        echo "Running with New Relic version $NEW_RELIC_VERSION, license_key: [$NEW_RELIC_LICENSE_KEY], app_name: [$NEW_RELIC_APP_NAME]"
        exec java -javaagent:/opt/newrelic/newrelic.jar -Dnewrelic.config.license_key=$NEW_RELIC_LICENSE_KEY -Dnewrelic.config.app_name=$NEW_RELIC_APP_NAME $JVM_PARAMS -jar /app.jar
    else
        exec java $JVM_PARAMS -jar /app.jar
    fi
fi 