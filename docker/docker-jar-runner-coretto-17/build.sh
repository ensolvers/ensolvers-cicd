tag=$(git rev-parse HEAD)
docker build . -t jar-runner-coretto-17:$tag
