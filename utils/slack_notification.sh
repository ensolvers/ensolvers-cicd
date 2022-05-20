#!/bin/bash

function slack_notification {
  TEXT=$1

  if [ "${2-}" != "-ignore-echo" ]; then
    echo "${TEXT}"
  fi

  if [ -n "$SLACK_WEBHOOK_URL" ]
  then
    curl -X POST -d "{'text':'${TEXT}'}" "$SLACK_WEBHOOK_URL"
  fi
}