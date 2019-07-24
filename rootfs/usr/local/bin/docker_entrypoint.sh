#!/usr/bin/env bash

set -o errexit          # Exit on most errors (see the manual)
#set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
#set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

RBFEEDER_INI=/etc/rbfeeder.ini

source ini_val.sh

echo -n "" > ${RBFEEDER_INI}
{
  echo '[client]'
  echo '[mlat]'
  echo 'autostart_mlat=true'
} >> ${RBFEEDER_INI}

ini_val ${RBFEEDER_INI} client.lat ${MLAT_CLIENT_LATITUDE:-0}
ini_val ${RBFEEDER_INI} client.lon ${MLAT_CLIENT_LONGITUDE:-0}
ini_val ${RBFEEDER_INI} client.alt ${MLAT_CLIENT_ALTITUDE:-0}
ini_val ${RBFEEDER_INI} mlat.autostart_mlat true


echo "Waiting for dump1090 to start up"
sleep 5s

exec /usr/bin/rbfeeder \
  --set-key ${RADARBOX24_KEY} \
  --set-network-mode on \
  --set-network-host $(getent hosts ${DUMP1090_HOST:-dump1090} | head -n 1 | awk '{print $1}') \
  --set-network-port ${DUMP1090_PORT:-30005} \
  --set-network-protocol ${DUMP1090_PROTOCOL:-beast} \
  ${@}
