#!/bin/bash

set -e

# Check if the AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install the AWS CLI and configure it."
    exit 1
fi

# Check if the required arguments are provided
if [[ $# -lt 3 ]]; then
    echo "Usage: bash deploy.sh <function_folder> <aws_region> <function_name>"
    exit 1
fi

# Prepare variables
function_folder=$1
aws_region=$2
function_name=$3
zip_output_file="function.zip"

# Move to function folder and run a cleanup: we remove old zip files and node_modules folders
cd $function_folder
echo "Cleaning folder..."
rm -rf $zip_output_file
find . -name "node_modules" -type d -prune -exec rm -rf {} +

# Install dependencies using yarn in production mode
echo "Installing dependencies..."
yarn install --production=true

# Zip the Lambda function code
echo "Creating ZIP file..."
zip -r $zip_output_file . -x '*.git*'

# Get the size of the final ZIP file
ZIP_SIZE=$(du -h $zip_output_file | awk '{print $1}')

# Print the final ZIP size
echo "Final ZIP file size: $ZIP_SIZE"

# Update the Lambda function code
echo "Updating Lambda function code..."
aws lambda update-function-code \
  --region $aws_region \
  --function-name $function_name \
  --zip-file fileb://$zip_output_file >> /dev/null

echo "Waiting function to be ready..."
aws lambda wait function-active --function-name "$function_name"

echo "Deploying new version..."
function_arn=$(aws lambda publish-version \
  --function-name $function_name --query 'FunctionArn' --output text)

# Check if the function code was updated successfully
if [ $? -eq 0 ]; then
  echo "Lambda function code updated successfully (arn = $function_arn)."
else
  echo "Failed to update Lambda function code."
fi
