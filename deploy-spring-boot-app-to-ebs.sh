#!/bin/bash
set -eu
BASEDIR=$(dirname "$0")

$BASEDIR/utils/check-aws-env.sh

echo "[$(date)] Building app..."
mvn clean install spring-boot:repackage -DskipTests

echo "[$(date)] Deploying to Elastic Beanstalk..."
eb deploy --staged --verbose 
