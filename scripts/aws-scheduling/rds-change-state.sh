#!/bin/bash

CLUSTER_NAME=$1
ACTION=$2
IS_AURORA=$3

if [ -z "$IS_AURORA" ] ; then
  IS_AURORA=true;
fi

if [ -z "$CLUSTER_NAME" ] || [ -z "$ACTION" ] ; then
    echo "[ERROR] Expected 2 params: correct usage --> ./ecs-set-service-size.sh <CLUSTER_NAME> <ACTION> <IS_AURORA>"
    exit 1
fi

aws lambda invoke \
  --function-name "updateRdsInstances" \
  --cli-binary-format raw-in-base64-out \
  --payload "{\"clusterIdentifier\": \"$CLUSTER_NAME\", \"isCustom\": $IS_AURORA, \"action\": \"$ACTION\"}" last-execution-result.json