CONTAINER_NAME=dev-container

docker build \
  . \
  -t ${CONTAINER_NAME}

docker run \
  -it \
  -w /usr/src/twostepsfromcode \
  --volume ${PWD}:/usr/src/twostepsfromcode \
  --entrypoint /bin/zsh \
  ${CONTAINER_NAME}