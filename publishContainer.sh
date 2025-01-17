#!/usr/bin/env bash
set -eo pipefail

#use to build with no deps: CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o build/appetizer .
echo "building appetizer"
go build -o build/appetizer main.go
ls -l build/appetizer

echo "<html><body>$(git rev-parse --short HEAD)</body></html>" > http_content/version.html


if [ "local" == "${1}" ]; then
  echo "LOADING LOCALLY instead of pushing to dockerhub"
  _BUILDX_PLATFORM=""
  _BUILDX_ACTION="--load"
  _TAG="local"
else
  _BUILDX_PLATFORM="--platform linux/amd64,linux/arm64"
  _BUILDX_ACTION="--push"
  _TAG="latest"
fi

docker buildx create \
  --use --name=ziti-ziti-appetizer-builder --driver docker-container 2>/dev/null \
  || docker buildx use --default ziti-ziti-appetizer-builder
  
  
eval docker buildx build "${_BUILDX_PLATFORM}" "." \
  --tag "openziti/appetizer:${_TAG}" \
  "${_BUILDX_ACTION}"

