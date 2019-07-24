FROM debian:stretch-slim AS base

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	librtlsdr0 \
	libusb-1.0-0 \
	libcurl3-gnutls \
	libglib2.0-0 \
	libc6 \
	netbase \
	python3 && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM --platform=$TARGETPLATFORM debian:stretch-slim as builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    dirmngr gnupg2 ca-certificates apt-transport-https 

RUN mkdir ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

RUN DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 1D043681

RUN echo 'deb https://apt.rb24.com/ rpi-stable main' > /etc/apt/sources.list.d/rb24.list
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    rbfeeder

FROM --platform=$TARGETPLATFORM alpine as mlat

RUN apk add --no-cache \
	curl \
	ca-certificates \
	python3 \
	python3-dev \
	gcc \
	libc-dev

ARG MLAT_CLIENT_VERSION=v0.2.10
ARG MLAT_CLIENT_HASH=8a570fd502bbba39b37175eff6dbab8372ed1a878266ff96fb33cd65f46eacef

RUN curl --output mlat-client.tar.gz -L "https://github.com/mutability/mlat-client/archive/${MLAT_CLIENT_VERSION}.tar.gz" && \
    sha256sum mlat-client.tar.gz && echo "${MLAT_CLIENT_HASH}  mlat-client.tar.gz" | sha256sum -c
RUN pip3 install --upgrade shiv importlib-resources==0.8
RUN \
	tar -xvf mlat-client.tar.gz && \
	cd mlat-client-0.2.10 && \
	mv mlat-client mlat/client/cli.py && \
	mv fa-mlat-client flightaware/client/cli.py && \
	sed '$d' < setup.py > setup.py2 ; mv setup.py2 setup.py && \
	echo "      entry_points = {" >> setup.py && \
	echo "        'console_scripts': [" >> setup.py && \
	echo "          'mlat-client=mlat.client.cli:main'," >> setup.py && \
	echo "          'fa-mlat-client=flightaware.client.cli:main'," >> setup.py && \
	echo "          ]," >> setup.py && \
	echo "      })" >> setup.py && \
	shiv --python='/usr/bin/env python3' -c mlat-client -o /usr/bin/mlat-client .
FROM base

COPY rootfs /

COPY --from=builder /usr/bin/rbfeeder /usr/bin/rbfeeder
COPY --from=mlat /usr/bin/mlat-client /usr/bin/mlat-client

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
