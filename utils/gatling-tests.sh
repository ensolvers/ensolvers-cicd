#!/bin/bash

TEST_DIR="$1"
SIMULATION_CLASS="$2"
GATLING_ARGS="$3"
REPORT_FILE_S3_URL="$4"/$(echo "SIMULATION_CLASS" | awk -F "." '{print $NF}')/$(date +%s).html

echo "Dir: $TEST_DIR"
echo "Class: $SIMULATION_CLASS"
echo "Args: $GATLING_ARGS"

cd $TEST_DIR

mvn gatling:test -Dgatling.simulationClass=$SIMULATION_CLASS $GATLING_ARGS

aws s3 cp "$(find . -name index.html)" "$REPORT_FILE_S3_URL"