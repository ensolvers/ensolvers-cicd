tag=$(git rev-parse HEAD)
timezone="${1:-UTC}"

docker build . -t jar-runner-coretto-21-alpine:$tag --build-arg timezone=$timezone
