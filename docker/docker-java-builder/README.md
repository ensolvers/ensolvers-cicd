# Introduction

`docker-java-builder` is a Docker image prepared to build any Java project that can be easily configured to use any Java flavor available, including also some basic toolset for working with AWS (AWS CLI, `jq` for parsing JSON responses, among others)

# Building

Simply invoke `build-and-deploy-jdk8.sh` or `build-and-deploy-jdk11.sh` providing the repo URL to which the final version of the image should be uploaded. 

Alternatively, you can invoke `deploy.sh` just providing the Java flavor you want to use via the `JAVA_FLAVOR` env var. The Dockerfile users [Jabba](https://github.com/shyiko/jabba) for downloading and installing the JDK, so if you want to know the current flavors just install it and run `jabba ls`.