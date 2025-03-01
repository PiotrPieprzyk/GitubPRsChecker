#!/bin/bash


parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

if [ -f ../../github-token.txt ]; then
  CLI_TOKEN=$(cat ../../github-token.txt)
else
  echo "File ../../github-token.txt does not exist"
  exit 1
fi

# Update following variables if needed
authors="piotrlatala ArekEvo aleksander-pisarek PiotrPieprzyk"
repositories="EENCloud/WEB-VMS-WebApp EENCloud/frontend-gui EENCloud/WEB-EEWC-Components EENCloud/WEB-Floor-Plan"
days=2

docker compose build \
  && docker compose run \
    -e CLI_TOKEN="$CLI_TOKEN" \
    -e authors="$authors" \
    -e repositories="$repositories" \
    -e days="$days" \
    development
