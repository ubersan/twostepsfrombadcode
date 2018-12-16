#!/bin/sh

CONTAINER_NAME=tsfbc-dev-container

docker build \
  . \
  -t ${CONTAINER_NAME}

docker run \
  -it \
  -p 4000:4000 \
  --volume ~/.gitconfig:/etc/gitconfig \
  --volume ~/.ssh:/root/.ssh \
  --volume ${PWD}:${PWD} \
  --workdir ${PWD} \
  ${CONTAINER_NAME}