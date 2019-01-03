#!/usr/bin/env bash

CONTAINER_NAME=tsfbc-dev-container

mkdir -p ${HOME}/.docker ${HOME}/.ssh
touch  ${HOME}/.gitconfig

docker build \
  . \
  -t ${CONTAINER_NAME}

docker run -it \
  --env HISTFILE=${PWD}/.zsh_history \
  --privileged \
  --rm \
  --user `id -u`:`id -g` \
  --volume /var/run/docker.sock:/var/run/docker.host.sock \
  --publish 4000:4000 \
  --volume ${HOME}/.gitconfig:/home/developer/.gitconfig \
  --volume ${HOME}/.docker:/home/developer/.docker \
  --volume ${HOME}/.ssh:/home/developer/.ssh \
  --volume ${PWD}:${PWD} \
  --workdir ${PWD} \
  ${CONTAINER_NAME}
