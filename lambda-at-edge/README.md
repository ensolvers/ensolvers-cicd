# ensolvers-lambda-at-edge

This folder contains a set of files to simplify lambda@edge function provisioning and deployment. Basically lambda@edge consist in 4 functions that an be attached to AWS Cloudfront behaviours to fine-tune how requests to the CDN will behave.

## Function creation
You can create new functions by using `setup/function-template.yaml` CloudFormation template. That template takes a prefix and creates the following functions:

- $PREFIX-viewer-response
- $PREFIX-viewer-request
- $PREFIX-origin-response
- $PREFIX-origin-request

Those functions are empty initially, but their names match the structure that will be described below for deploying them - we just need to use the same prefix

## Deployment
Deploying the function can be accomplished by running `setup/deploy-suite.sh` providing the correct folder when the functions are located, the region and the prefix for the remote function names.

For instance, let's assume that we have folder in which we have the following sub-folders
- viewer-request
- viewer-response

And we have the following lambdas created in our QA environment
- qa-viewer-request
- qa-viewer-response

We need to call `setup/deploy-suite.sh path_to_folder us-east-1 qa`

This will build both functions, deploy it to their corresponding functions in AWS and run a new version
