#!/bin/bash

SERVICE_NAME=$1
EXPECTED_INSTANCES=$2

if [ -z "$SERVICE_NAME" ] || [ -z "$EXPECTED_INSTANCES" ]  ; then
    echo "[ERROR] Expected 2 params: correct usage --> ./ecs-set-service-size.sh <SERVICE_NAME> <EXPECTED_INSTANCES>"
    exit 1
fi

aws lambda invoke \
  --function-name "updateEcsTasks" \
  --cli-binary-format raw-in-base64-out \
  --payload "{\"cluster\": \"$SERVICE_NAME\", \"service\": \"$SERVICE_NAME\", \"instances\": $EXPECTED_INSTANCES}" last-execution-result.json