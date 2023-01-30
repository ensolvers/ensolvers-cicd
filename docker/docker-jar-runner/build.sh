tag=$(git rev-parse HEAD)
docker build . -t docker-jar-runner:$tag
