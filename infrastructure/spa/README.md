# React app deployment into S3 bucket

This section contains a detailed guide on how to provision infrastructure for hosting a React app and serve it via a CDN. Let's start with the infrastructure

# Infrastructure for SPA deployment


1. Go to AWS Route53 console, register the domain in Hosted Zone
2. Go to AWS Certificate Manager and request a certificate for the domain, follow the steps to get the domain validated and the cert issued
3. Go to CloudFormation console, create a new stack using [Frontend.yaml](Frontend.yam) template
4. Enter the following details
- Hosted Zone: same zone that was registered in Step 1
- Subdomain: the desired subdomain - if we want to host the app on the root domain (no subdomain) no worries, we can configure it later
- AcmCertificateArn: use the ARN of the certificate issued in (3)

### Deployment process

The script [deploy-react-app-to-s3.sh](../../deploy-react-app-to-s3.sh) allows to build and deploy React applications to S3 buckets - that can be distributed via Cloudfront.

The script assumes the following

- The app is created with Next.js - if not, at least the source code should be included in a `src` folder at project root, a `build` script should be part of `package.json`
- The environment-related properties for the app are located in `src/environment.json`. Properties files for other environments should reside in `src` as well.
- The module name (folder inside `modules/`) of the app will be passed to this script as an argument.

### Manual Deploy
A template invocation can be find on [templates/react-deploy-example.sh](../../templates/react-deploy-example.sh)

The script requires the following parameters:

- `ENVIRONMENT_FILE`:  Name of the environment file to used (it should be within `src` at the same level than `environment.json`)
- `S3_BUCKET`: Name of the bucket in which the app will be deployed
- `CLOUDFRONT_DISTRIBUTION_ID`: ID of the Cloudfront distribution that takes the S3 bucket as a source
- The module name (folder inside `modules/`) of the app should be passed to `deploy-react-app-to-s3.sh` script as an argument.

### Automatic Deploy
You can automate builds and deploys to s3 with a code build project:

- Copy [buildspec-react.yml](../../templates/buildspec-react.yml) file to your project.
- Create the project for the environment in codebuild, you will need to define the following env vars:
    1. `ENV`: the environment (qa, prod, etc...).
    2. `BRANCH`/`TAG`: branch/tag of the base code that will be used to perform the build, by default it will use master.
    3. `SLACK_WEBHOOK_URL`: specify a slack webhook url to send notifications.
    4. `SUBMODULE_BRANCH`: branch of the submodules base code that will be used to perform the build.
    5. `REACT_APP_PATH`: Path of the root folder of the React app
    6. `ENVIRONMENT_FILE`:  Name of the environment file to used (it should be within `src` at the same level than `environment.json`).
    7. `S3_BUCKET`: Name of the bucket in which the app will be deployed.
    8. `CLOUDFRONT_DISTRIBUTION_ID`: ID of the Cloudfront distribution that takes the S3 bucket as a source.
