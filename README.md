# Ensolvers CI/CD

This project includes a series of scripts and utils to simplify CI/CD processes, including app building, testing, etc.

## Spring Boot app deployment in AWS Elastic Beanstalk

Deploying Spring Boot applications into AWS Elastic Beanstalk can be done simply by calling
[deploy-spring-boot-app-to-ebs.sh](deploy-spring-boot-app-to-ebs.sh) 

However, it requires the app to be properly configured. To configure an existing app just copy [config.yml](templates/elasticbeanstalk/config.yml) file into `.elasticbeankstalk/config.yml in your project and replace the variables with the concrete values for app, environment, etc.

Also, ensure that you have the [EBS CLI installed](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html)

## React app deployment into S3 bucket

The script [deploy-react-app-to-s3.sh](deploy-react-app-to-s3.sh) allows to build and deploy React applications to S3 buckets - that can be distributed via Cloudfront.

The script assumes the following

- The app is created with create-react-app - if not, at least the source code should be included in a `src` folder at project root, a `build` script should be part of `package.json`
- The environment-related properties for the app are located in `src/environment.json`. Properties files for other environments should reside in `src` as well.

The script requires the following parameters:

- `REACT_APP_PATH`: Path of the root folder of the React app
- `ENVIRONMENT_FILE`:  Name of the environment file to used (it should be within `src` at the same level than `environment.json`)
- `S3_BUCKET`: Name of the bucket in which the app will be deployed
- `CLOUDFRONT_DISTRIBUTION_ID`: ID of the Cloudfront distribution that takes the S3 bucket as a source