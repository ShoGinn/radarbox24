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

RUN DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 1D043681

RUN echo 'deb https://apt.rb24.com/ rpi-stable main' > /etc/apt/sources.list.d/rb24.list
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    rbfeeder mlat-client

FROM base

COPY rootfs /

COPY --from=builder /usr/bin/rbfeeder /usr/bin/rbfeeder
COPY --from=builder /usr/bin/mlat-client /usr/bin/mlat-client
COPY --from=builder /usr/lib/python3/dist-packages/mlat/ /usr/lib/python3/dist-packages/mlat/
COPY --from=builder /usr/lib/python3/dist-packages/_modes.cpython-35m-arm-linux-gnueabihf.so \
		    /usr/lib/python3/dist-packages/_modes.cpython-35m-arm-linux-gnueabihf.so

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
