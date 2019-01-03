#!/usr/bin/env bash

eval $(run-parts /etc/docker-entrypoint.d)

exec zsh
