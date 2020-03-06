# radarbox24

Docker container for ADS-B - This is the radarbox24.com component

This is part of a suite of applications that can be used if you have a dump1090 compatible device including:

* Any RTLSDR USB device
* Any network AVR or BEAST device
* Any serial AVR or BEAST device

## Container Requirements

This is a multi architecture build that supports arm (armhf) (no amd64 or arm64 att due to no repo!)

You must first have a running setup for before using this container as it will not help you on initial setup

## Container Setup

Env variables must be passed to the container containing the radarbox24 required items

If you want to use mlat, please use my mlat container in addition!

See [Mlat Docker]((https://github.com/ShoGinn/adsbexchange-mlat))

### Defaults

* DUMP1090_SERVER=dump1090 -- make sure your dump1090 container is named this and on the same network (can change)
* DUMP1090_PORT=30005 -- default port (can change)
* DUMP1090_PROTOCOL=beast - defaults to the beast protocol to feed

### User Configured

* RADARBOX24_KEY - This is your user specific key

#### Example docker run

```bash
docker run -d \
--restart unless-stopped \
--name='radarbox24' \
-e RADARBOX24_KEY="321349dd" \
shoginn/radarbox24:latest

```

## Status

| branch | Status |
|--------|--------|
| master | [![Build Status](https://travis-ci.org/ShoGinn/radarbox24.svg?branch=master)](https://travis-ci.org/ShoGinn/radarbox24) |
