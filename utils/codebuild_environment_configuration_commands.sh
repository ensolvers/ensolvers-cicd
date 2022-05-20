set -e

BASEDIR=$(dirname "$0")

#load utils
source "$BASEDIR/slack_notification.sh"
source "$BASEDIR/error_handler.sh"

# Configure code base and submodules
slack_notification "[$(echo "$ENV" | tr '[:lower:]' '[:upper:]')] [$(date +"%H:%M:%S") UTC-3] - Deploy started by \`$CODEBUILD_INITIATOR\`"

echo "Configuring extra vars"
export MAVEN_CONFIG=''
export _JAVA_OPTIONS=-Xmx12g
export ROOT_DIR=$PWD
echo "Extra vars configured"

echo "Configuring branch/tag"
if [ -z "$TAG" ]; then
  build_source="$BRANCH"
  sub_build_source="$SUBMODULE_BRANCH"
else
  build_source="$TAG"
  sub_build_source="$TAG"
fi
echo "Branch/tag configured"

echo "Configuring submodules"
git checkout $build_source
sed -i "s|git@github.com:|https://github.com/|g" .gitmodules
git submodule update --init --recursive
git submodule foreach git checkout $sub_build_source
echo "Submodules configured"