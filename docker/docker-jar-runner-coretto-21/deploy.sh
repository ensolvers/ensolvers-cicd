#!/bin/bash
repo=$1
timezone="${2:-UTC}"

if [[ -z $repo ]]; then
    echo "Usage $0 <repo> <timezone>, e.g.: $0 238750409794.dkr.ecr.us-east-1.amazonaws.com/jar-runner UTC"
    exit 1;
fi

./build.sh $timezone

docker tag jar-runner-coretto-21:$tag $repo:$tag
docker push $repo:$tag