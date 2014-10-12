#!/bin/sh

set -ex

docker run \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $PWD:/app \
	-t --rm elixir-build \
	/bin/bash -c "set -ex; cd /app; mix do deps.get, dock"


