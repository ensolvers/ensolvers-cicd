set -e

error_handler_slack_message() {
  curl -X POST -d "{'text':':alert-red: AN ERROR OCCURRED :alert-red:'}" "$SLACK_WEBHOOK_URL"
}

trap "error_handler_slack_message" ERR