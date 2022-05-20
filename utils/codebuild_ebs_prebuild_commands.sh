set -e

BASEDIR=$(dirname "$0")

source "$BASEDIR/error_handler.sh"

# Install ebs cli
echo "Installing EBS CLI..."
git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
python ./aws-elastic-beanstalk-cli-setup/scripts/ebcli_installer.py
export PATH="/root/.ebcli-virtual-env/executables:$PATH"
echo "EBS CLI installed"

source $BASEDIR/codebuild_environment_configuration_commands.sh