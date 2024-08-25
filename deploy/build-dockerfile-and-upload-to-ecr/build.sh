#!/bin/bash
set -e 

# Check if required environment variables are set
if [[ -z $AWS_DEFAULT_REGION || -z $AWS_ACCOUNT_ID || -z $AWS_ECR_REPOSITORY_NAME || -z $BUILD_SCRIPT_NAME ]]; then
    echo "One or more required environment variables are not set:"
    echo " - AWS_DEFAULT_REGION: Please set it with the appropriate AWS region."
    echo " - AWS_ACCOUNT_ID: Please set it with your AWS account ID."
    echo " - AWS_ECR_REPOSITORY_NAME: Please set it with the name of your ECR repository."
    echo " - BUILD_SCRIPT_NAME: Name of the script that will build the image."
    echo " - IMAGE_NAME (optional): Name of the image that will be used locally. If not provided, it will default to AWS_ECR_REPOSITORY_NAME"
    echo " - DOCKERFILE_PATH (optional): Path of the Dockerfile that will be used to build the image. If not provided, it will assume that is located in the current directory."
    exit 1
fi

: "${IMAGE_NAME:=$AWS_ECR_REPOSITORY_NAME}"

echo "Retrieving the latest commit hash..."
GIT_HASH=$(git rev-parse --short HEAD)
IMAGE_TAG="$IMAGE_NAME:$GIT_HASH"

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

echo "Invoking building script..."
./$BUILD_SCRIPT_NAME $IMAGE_TAG

echo "Building docker image"
if [[ -z $DOCKERFILE_PATH ]]; then
    docker build -t $IMAGE_TAG .
else
    docker build -t $IMAGE_TAG -f $DOCKERFILE_PATH .
fi

echo "Tagging the image with the full repository URI..."
docker tag $IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$AWS_ECR_REPOSITORY_NAME:$GIT_HASH

echo "Pushing the image to the ECR repository..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$AWS_ECR_REPOSITORY_NAME:$GIT_HASH