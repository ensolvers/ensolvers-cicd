set -e

error_handler() {
  curl -X POST -d "{'text':':alert-red: AN ERROR OCCURRED :alert-red:'}" "$SLACK_WEBHOOK_URL"
}

trap "error_handler" ERR