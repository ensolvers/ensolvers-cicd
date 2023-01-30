# docker-sonarcloud

The purpose of this module is to quickly describe how Docker can be set up to run SonarQube tests

## Docker Image

For the purpose of analyzing Java apps, the [docker-java-builder](../docker-java-builder/README.md) fulfills all the technical requirements for this, ensure that this image is deployed to your repo

## Scripting

### Basic analysis

Just running 

```
mvn -fn clean verify sonar:sonar -DskipTests -Dsonar.login=<token> 
```

should be enough for running the tests. If you are using AWS CodeBuidl, you can use the following buildspec 

```
version: 0.2

phases:
  build:
    commands:
      - mvn -fn clean verify sonar:sonar -DskipTests -Dsonar.login=<token>

```

both directly in a buildspec.yaml file or as a manual command

### Test coverage 

To be done

### Caching maven dependencies

By avoiding to download all Maven dependency each time the analysis runs, we can drastically reduce analysis time. The safest and simplest way to do this is simply using S3 for caching those dependencies.

```
version: 0.2

phases:
  build:
    commands:
      - mkdir -p ~/.m2/repository; aws s3 sync ~/.m2/repository s3://<bucket-name>
      - mvn -fn clean verify sonar:sonar -DskipTests -Dsonar.login=<token>
      - aws s3 sync s3://<bucket-name> ~/.m2/repository

```


By using [docker-java-builder](../docker-java-builder/README.md), you also should be able to cache 