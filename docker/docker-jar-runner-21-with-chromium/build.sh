tag=$(git rev-parse HEAD)
timezone="${1:-UTC}"

docker build . -t jar-runner-ubuntu-21-chromium:$tag --build-arg timezone=$timezone
