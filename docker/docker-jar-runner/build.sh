tag=$(git rev-parse HEAD)
docker build . -t jar-runner:$tag
