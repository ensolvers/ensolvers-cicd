tag=$(git rev-parse HEAD)
timezone="${1:-UTC}"

docker build . -t jar-runner-coretto-21:$tag --build-arg timezone=$timezone
