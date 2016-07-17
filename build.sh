#!/bin/bash

DOCKER_NAMESPACE="${DOCKER_NAMESPACE:-sabayon}"
IMAGE_DIR="${1}"
IMAGE="${2}"

die() { echo "$@" 1>&2 ; exit 1; }

pushd $IMAGE_DIR
  docker build --rm -t $IMAGE .
  docker push $IMAGE
popd
