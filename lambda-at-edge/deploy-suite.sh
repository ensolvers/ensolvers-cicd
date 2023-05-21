suite_path=$1
aws_region=$2
prefix=$3
dir=$(dirname "$0")

if [[ $# -lt 3 ]]; then
    echo "Usage: bash deploy-suite.sh <suite_path> <aws_region> <prefix>"
    exit 1
fi

if [ -d "$suite_path/viewer-request" ]; then
    echo "viewer-request found, deploying..."
    $dir/deploy.sh $suite_path/viewer-request $aws_region $prefix-viewer-request 
fi

if [ -d "$suite_path/viewer-response" ]; then
    echo "viewer-response found, deploying..."
    $dir/deploy.sh $suite_path/viewer-response $aws_region $prefix-viewer-response 
fi

if [ -d "$suite_path/origin-request" ]; then
    echo "origin-request found, deploying..."
    $dir/deploy.sh $suite_path/origin-request $aws_region $prefix-origin-request 
fi

if [ -d "$suite_path/origin-response" ]; then
    echo "origin-response found, deploying..."
    $dir/deploy.sh $suite_path/origin-response $aws_region $prefix-viewer-response 
fi

echo "Deployment finished"