set -e

BASEDIR=$(dirname "$0")

#load utils
source "$BASEDIR/slack_notification.sh"
source "$BASEDIR/error_handler_slack_message.sh"

# Configure code base and submodules
slack_notification "[${ENV^^}] [$(date +"%H:%M:%S") UTC] - Deploy started by \`${CODEBUILD_INITIATOR}\`"

echo "Branch configured: [$BRANCH]"

git checkout $build_source

# Use HTTPS instead of SSH since env setup is simpler
sed -i "s|git@github.com:|https://github.com/|g" .gitmodules
git submodule update --init --recursive