#!/bin/bash

# Ensure that the environment is specified and valid
if [ -z "$ENV" ]; then
    echo "Error: Missing environment."
    echo "Please specify the deployment environment using the 'ENV' variable."
    echo "Valid environments are 'qa' and 'prod'."
    exit 1
fi

if [ "$ENV" != "qa" ] && [ "$ENV" != "prod" ]; then
    echo "Error: Invalid environment specified."
    echo "Valid environments are 'qa' and 'prod'."
    exit 1
fi

# Ensure that the app path is specified
if [ -z "$APP_PATH" ]; then
    echo "Error: Missing app path."
    echo "Please specify the application root path using the 'APP_PATH' variable."
    echo "This should be the directory where the /src directory is located."
    exit 1
fi

# Ensure the app path exists
if [ ! -d "$APP_PATH/src" ]; then
    echo "Error: Invalid app path specified."
    echo "The specified app path does not contain a /src directory."
    exit 1
fi

# Load environment-specific configuration
ENV_FILE="$APP_PATH/src/environment-${ENV}.json"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment configuration file not found."
    echo "Expected file: $ENV_FILE"
    exit 1
fi

# Ensure that all required environment variables are set
if [ -z "$S3_BUCKET_NAME" ] || [ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo "Error: Missing required environment variables."
    echo "The following environment variables must be defined in $ENV_FILE:"
    echo "  S3_BUCKET_NAME: The name of the S3 bucket where the site will be uploaded."
    echo "  CLOUDFRONT_DISTRIBUTION_ID: The CloudFront distribution ID that will be invalidated."
    exit 1
fi

# Set default build directories if not defined
DIST_DIR=${DIST_DIR:-"out"}      # Default output directory after exporting Next.js app

# Change to the app directory
cd "$APP_PATH"

# Build the Next.js app
echo "Building Next.js app..."
npm run build

# Export the Next.js app (optional, if using static export)
echo "Exporting Next.js app..."
npm run export

# Sync the build directory to the S3 bucket
echo "Uploading to S3..."
aws s3 sync $DIST_DIR s3://$S3_BUCKET_NAME --delete

# Invalidate CloudFront cache
echo "Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*" --output text --query 'Invalidation.Id')

# Wait for the invalidation to complete (optional)
echo "Waiting for invalidation to complete..."
aws cloudfront wait invalidation-completed --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --id $INVALIDATION_ID

echo "Deployment complete!"