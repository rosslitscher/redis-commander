#!/bin/bash

tgt=$(mktemp -d)

cp -r . $tgt

cat <<SF >${tgt}/redis-commander-k8s.sh
#!/bin/bash
node /usr/src/redis-commander/bin/redis-commander.js --sentinel-host=\${REDIS_SENTINEL_SERVICE_HOST} --sentinel-port=\${REDIS_SENTINEL_SERVICE_PORT}
SF
chmod +x ${tgt}/redis-commander-k8s.sh

cat <<DF >${tgt}/Dockerfile
# Simple Dockerfile to execute redis-commander from docker
# build it with like: docker build -t redis-commander .
# to run: docker run -d --name redis-commander -p 8081:8081 redis-commander -- --redis-host your-redis-host
FROM docker.io/node:0.10.38

RUN mkdir -p /usr/src
WORKDIR /usr/src

ADD ./ /usr/src/redis-commander/
RUN cd redis-commander \
	&& npm install

ENTRYPOINT [ "/usr/src/redis-commander/redis-commander-k8s.sh" ]

EXPOSE 8081
DF

docker build -t tangfeixiong/redis-commander:joeferner $tgt
rm -rf $tgt
