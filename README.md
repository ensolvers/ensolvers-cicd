# Ensolvers CI/CD

This project includes a series of scripts and utils to simplify CI/CD processes, including app building, testing, etc.

## Spring Boot app deployment in AWS Elastic Beanstalk

Deploying Spring Boot applications into AWS Elastic Beanstalk can be done simply by calling
[deploy-spring-boot-app-to-ebs.sh](deploy-spring-boot-app-to-ebs.sh) 

However, it requires the app to be properly configured. To configure an existing app just copy [config.yml](templates/elasticbeanstalk/config.yml) file into `.elasticbeankstalk/config.yml` in your project and replace the variables with the concrete values for app, environment, etc.

### Manual Deploy
- Ensure that you have the [EBS CLI installed](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html)
- Configure AWS user with env vars (`AWS_REGION`, `AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- From the root of your project call the script [deploy-spring-boot-app-to-ebs.sh](deploy-spring-boot-app-to-ebs.sh):
  `bash submodules/ensolvers-cicd/deploy-spring-boot-app-to-ebs.sh <MODULE_NAME_TO_DEPLOY>`

### Automatic Deploy
You can automate builds and deploys to EBS with a code build project:

- Copy [buildspec-spring.yml](templates/elasticbeanstalk/buildspec-spring.yml) file to your project.
- Create the project for the environment in codebuild, you will need to define the following env vars:
  1. `ENV`: The environment (qa, prod, etc...).
  2. `BRANCH`/`TAG`: branch/tag of the base code that will be used to perform the build, by default it will use master.
  3. `SLACK_WEBHOOK_URL`: Specify a slack webhook url to send notifications.
  4. `SUBMODULE_BRANCH`: branch of the submodules base code that will be used to perform the build.
  5. `MODULES`: space separated string. Each value in the list indicates the module that will be built and deployed to its corresponding EBS application.

## Spring Boot app deployment in AWS Elastic Container Service

Deploying Spring Boot applications into AWS Elastic Container Service can be done simply by calling
[spring-boot-deploy-ecs.sh](spring-boot-deploy-ecs.sh)

However, it requires the app to be properly configured. To configure an existing app:

1. Copy [buildspec-spring.yml](templates/ecs/buildspec-spring.yml) file into `deploy/configuration/buildspec-spring.yml` in your project.


2. Copy [task-def.json](templates/ecs/task-def.json) file into `deploy/task-def.json` in your project.


3. For each environment you need to define a script in `deploy` directory, named `<ENV>-Var-Build.sh`. This script will set the corresponding environment variables for the defined `ENV`. 
Required vars that you need to define for each env:
   1. `ECS_TASK_EXECUTION_ROLE`: The role that the ECS task instance will use.
   2. `DOCKER_IMAGE`: The image of the container were the task instance will run (probably you will need to build an upload a custom image to aws ecr). In this case, we will probably use 
   `docker-jar-runner`, check [Docker Images](docker/README.md) documentation
   3. `AWS_REGION`: AWS region of the ECS cluster where the task will be deployed.
   4. `S3_BUCKET_NAME`: S3 bucket where the generated jar will be uploaded.
   5. `AWS_SECRET_MANAGER_SECRET_ARN`: Optional. Define this var if you need to use `secrets` section in task definition file. Example at the end of this section.

   **Note:** You have a template in [ENV-Var-Build.sh](templates/ecs/ENV-Var-Build.sh)


4. For each build project created in ECS you need to configure the following environment vars:
   1. `ENV`: The environment (qa, prod, etc...).
   2. `BRANCH`/`TAG`: branch/tag of the base code that will be used to perform the build, by default it will use master.
   3. `SLACK_WEBHOOK_URL`: optional. Specify a slack webhook url if you need to send notification to Slack.
   4. `KEY_ID`: KMS customer managed key to use to encrypt the build.
   5. `SUBMODULE_BRANCH`: branch of the submodules base code that will be used to perform the build.
   6. `APPS`: space separated string. Each value in this list along with the `ENV` value will be used to find and execute the configuration scripts for each jar that will be generated. More explanation below.


5. For each `APP` defined in `APPS` var you need to define a script in `deploy` directory, named `<ENV>-<APP>.sh`. This script will set the corresponding environment variables for the defined `ENV` and `APP`. Required vars that you need to define for each env:
   1. `MODULE_NAME`: module to be build.
   2. `CLUSTER_NAME`: the name of the ECS cluster where the task will be deployed.
   3. `VCPU`: The number of cpu units used by the task.
   4. `MEMORY`: The amount (in MiB) of memory used by the task.
   5. `SERVER_PORT`: port mapping for the container. Probably `8080`.

   **Note:** You have a template in [ENV-APP.sh](templates/ecs/ENV-APP.sh)

#### Example: Task definition secrets section
   ```
   ...
   "secrets": [
      {
        "name": "DB_PASSWORD",
        "valueFrom": "$AWS_SECRET_MANAGER_SECRET_ARN:db-password::"
      }
    ],
   ...
   ```
## React app deployment into S3 bucket

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

Just call this script from **your root project** directory passing it two parameters:

- Path to application properties.
- Path to test reports folder
- Base package to scan

Additionally, you can define the env variable `SLACK_WEBHOOK_URL` to send results to slack.

Example:
```
APP_PROPERTIES_PATH=./modules/simple-app-backend/src/test/resources/application.properties
REPORTS_PATH=./modules/simple-app-backend/target/surefire-reports
PACKAGE_NAME=com.simple.app
bash ./submodules/ensolvers-cicd/run-backend-tests.sh $APP_PROPERTIES_PATH $REPORTS_PATH
```

## Other useful guides / how-tos

* [New Relic integration in AWS Elastic Beanstalk](docs/New_Relic_Integration_EBS.md)