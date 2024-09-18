# Ensolvers CI/CD

This project includes a series of scripts and utils to simplify CI/CD processes, including app building, testing, etc.

## Backend infrastructure provisioning

- Regaring computing provisioning in AWS, we suggest to use EKS with Fargate. Steps and templates [can be found here](infrastructure/kubernetes/README.md). 
- For DB support, we suggest to use one of our templates for creating Aurora clusters
   - [MySQL-Aurora-8.0](templates/MySQL-Aurora-8.0.yaml): provision a MySQL 8.0-based RDS Aurora cluster

## Frontend infrastructure provisioning

We use Next.js as our default tech stack for frontend. 

For apps that include server-side rendering, we strongly suggest to use [Vercel](https://vercel.com) or another OOTB, scalable solution like [Cloudflare](https://developers.cloudflare.com/pages/framework-guides/nextjs/ssr/)

For apps that can be compiled into static sites, we have [our custom solution including S3, Cloudformation and S3](infrastructure/spa/README.md)

## General Cloudformation Templates

One of the key components that this repo includes is a set of Cloudformation templates that simplifies provisioning
infrastructure. Some of them are listed below:

- [MySQL-Instance-5.7](templates/MySQL-Instance-5.7.yaml): provision a MySQL 5.7 RDS instance
- [MySQL-Aurora-5.7](templates/MySQL-Aurora-5.7.yaml): provision a MySQL 5.7-based RDS Aurora cluster
- [Frontend](templates/Frontend.yaml): Assuming Route53 for domain management with a domain already configured, provisions a 
S3 bucket when we can store a SPA application, with a Cloudfront distribution as a CDN
- [ECS-With-LB](templates/ECS-With-LB.yaml): Provisions a ECS cluster with an ALB for balancing traffic. By default, an nginx 
Docker image is configured for testing purposes

## Docker images

This repo features a set of Docker images that we use for different purposes - from deployment and general task to running apps in production.

Documentation can be found [here](/docker/README.md)

## React app deployment into S3 bucket

This section contains a detailed guide on how to provision infrastructure for hosting a React app and serve it via a CDN. Let's start with the infrastructure

### Infrastructure for SPA deployment


1. Go to AWS Route53 console, register the domain in Hosted Zone
2. Go to AWS Certificate Manager and request a certificate for the domain, follow the steps to get the domain validated and the cert issued
3. Go to CloudFormation console, create a new stack using [Frontend.yaml](templates/Frontend.yaml) template
4. Enter the following details
- Hosted Zone: same zone that was registered in Step 1
- Subdomain: the desired subdomain - if we want to host the app on the root domain (no subdomain) no worries, we can configure it later
- AcmCertificateArn: use the ARN of the certificate issued in (3)

### Deployment process

The script [deploy-react-app-to-s3.sh](deploy-react-app-to-s3.sh) allows to build and deploy React applications to S3 buckets - that can be distributed via Cloudfront.

The script assumes the following

- The app is created with [create-react-app](https://reactjs.org/docs/create-a-new-react-app.html) - if not, at least the source code should be included in a `src` folder at project root, a `build` script should be part of `package.json`
- The environment-related properties for the app are located in `src/environment.json`. Properties files for other environments should reside in `src` as well.
- The module name (folder inside `modules/`) of the app will be passed to this script as an argument.

### Manual Deploy
A template invocation can be find on [templates/react-deploy-example.sh](templates/react-deploy-example.sh)

The script requires the following parameters:

- `ENVIRONMENT_FILE`:  Name of the environment file to used (it should be within `src` at the same level than `environment.json`)
- `S3_BUCKET`: Name of the bucket in which the app will be deployed
- `CLOUDFRONT_DISTRIBUTION_ID`: ID of the Cloudfront distribution that takes the S3 bucket as a source
- The module name (folder inside `modules/`) of the app should be passed to `deploy-react-app-to-s3.sh` script as an argument.

### Automatic Deploy
You can automate builds and deploys to s3 with a code build project:

- Copy [buildspec-react.yml](templates/buildspec-react.yml) file to your project.
- Create the project for the environment in codebuild, you will need to define the following env vars:
    1. `ENV`: the environment (qa, prod, etc...).
    2. `BRANCH`/`TAG`: branch/tag of the base code that will be used to perform the build, by default it will use master.
    3. `SLACK_WEBHOOK_URL`: specify a slack webhook url to send notifications.
    4. `SUBMODULE_BRANCH`: branch of the submodules base code that will be used to perform the build.
    5. `REACT_APP_PATH`: Path of the root folder of the React app
    6. `ENVIRONMENT_FILE`:  Name of the environment file to used (it should be within `src` at the same level than `environment.json`).
    7. `S3_BUCKET`: Name of the bucket in which the app will be deployed.
    8. `CLOUDFRONT_DISTRIBUTION_ID`: ID of the Cloudfront distribution that takes the S3 bucket as a source.

## Automatic backend tests
You can automate test execution using [run-backend-tests.sh](run-backend-tests.sh) (uses test containers).

Make sure to have the database available, with a root user and default access.
If you see any error with the environment, try to run again the schema.

Just call this script from **your root project** directory passing it two parameters:

- Path to application properties.
- Path to test reports folder
- Base package to scan

Make sure that the project uses Surefire in the pom.xml, **at least** version 2 onward.

Read [here](https://www.baeldung.com/maven-surefire-plugin) to make sure how to implement 
Surefire in a pom for the root.

Additionally, you can define the env variable `SLACK_WEBHOOK_URL` to send results to slack.

Example:
```
APP_PROPERTIES_PATH=./modules/simple-app-backend/src/test/resources/application.properties
REPORTS_PATH=./modules/simple-app-backend/target/surefire-reports
PACKAGE_NAME=com.simple.app
bash ./submodules/ensolvers-cicd/run-backend-tests.sh $APP_PROPERTIES_PATH $REPORTS_PATH $PACKAGE_NAME
```

Now, if you want to add reports in Sonar to the project, there are two more parameters that you can add.

Follow this doc to understand how to include Sonar to the project, but once that's done, you have to include both the
SONAR_TOKEN and the SONAR_PROJECT_KEY. The Token works for any user enabled to access the Project, in the account setting.
The Project Key can be seen in the Information tab of the Project.

Example:
```
APP_PROPERTIES_PATH=./modules/simple-app-backend/src/test/resources/application.properties
REPORTS_PATH=./modules/simple-app-backend/target/surefire-reports
PACKAGE_NAME=com.simple.app
SONAR_KEY=1234567890xxxxxxx
SONAR_PROJECT_KEY=archetype_archetype-web
bash ./submodules/ensolvers-cicd/run-backend-tests.sh $APP_PROPERTIES_PATH $REPORTS_PATH $PACKAGE_NAME $SONAR_KEY $SONAR_PROJECT_KEY
```

## Other useful guides / how-tos

* [New Relic integration in AWS Elastic Beanstalk](docs/New_Relic_Integration_EBS.md)
