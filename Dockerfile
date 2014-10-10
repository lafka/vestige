FROM dock:5000/debian:base
MAINTAINER Olav Frengstad <olav@tiny-mesh.com>

RUN apt-get update &&  apt-get install -y --no-install-recommends openssl git

# Release must be compiled in a intermediate build container
ADD ./rel/vestige /app/vestige

CMD /app/vestige/bin/vestige console
