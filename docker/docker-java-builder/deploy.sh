set -x

repo=$1

if [[ -z $repo ]]; then
    echo "Usage $0 <repo>, e.g. 238750409794.dkr.ecr.us-east-1.amazonaws.com/jar-runner"
    exit 1;
fi

if [[ -z $JAVA_FLAVOR ]]; then
    echo "JAVA_FLAVOR env var should be provided. Download jabba and check current flavors via `jabba ls`"
    exit 1;
fi


tag=$(git rev-parse HEAD)

docker build --build-arg JAVA_FLAVOR=$JAVA_FLAVOR . -t java-builder:$tag
docker tag java-builder:$tag $repo:$tag
docker push $repo:$tag