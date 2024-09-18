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
