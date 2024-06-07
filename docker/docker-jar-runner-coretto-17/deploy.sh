#!/bin/bash
repo=$1
timezone="${2:-UTC}"

if [[ -z $repo ]]; then
    echo "Usage $0 <repo> <timezone>, e.g.: $0 238750409794.dkr.ecr.us-east-1.amazonaws.com/jar-runner UTC"
    exit 1;
fi

tag=$(git rev-parse HEAD)

docker build . -t jar-runner-coretto-17:$tag --build-arg timezone=$timezone
docker tag jar-runner-coretto-17:$tag $repo:$tag
docker push $repo:$tag