#!/bin/sh
# call this when building a docker release

docker run \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(cd $(dirname "$0"); pwd):/app \
	-ti \
	--rm \
	elixir-build /bin/bash -c "cd /app; mix do deps.get, dock"
