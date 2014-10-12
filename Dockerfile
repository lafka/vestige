FROM dock:5000/elixir-build
MAINTAINER Olav Frengstad <olav@tiny-mesh.com>

RUN apt-get update &&  apt-get install -y --no-install-recommends \
	openssl \
	git \
	openssh-client \
	docker

# Release must be compiled in a intermediate build container
ADD ./rel/vestige /app/vestige
RUN chgrp -R daemon /app

# Setup consul
RUN mkdir -p /tmp/consulrc
ADD ./priv/vestige.json /tmp/consulrc/

# Setup supervised
RUN mkdir -p /etc/service && svsetup -u root -l daemon CREATE vestige && svsetup ENABLE vestige

# rewrite the runscript
RUN sed -i "s@vestige@/app/vestige/bin/vestige console@" `svdir`/vestige/run

WORKDIR /app/vestige
CMD [ -n "$ENV" ] && svscan /service || ( echo "Please set the ENV variable" && exit 1 )
