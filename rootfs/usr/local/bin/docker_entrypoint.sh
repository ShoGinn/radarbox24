#!/usr/bin/env sh

set -o errexit          # Exit on most errors (see the manual)
#set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
#set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

DUMP1090_SERVER=${DUMP1090_SERVER:=dump1090}
DUMP1090_PORT=${DUMP1090_PORT:=30005}

echo "Waiting for dump1090 to start up"
sleep 5s

exec /usr/bin/rbfeeder \
  --set-key ${RADARBOX24_KEY} \
  --set-network-mode on \
  --set-network-host $(getent hosts ${DUMP1090_HOST} | head -n 1 | awk '{print $1}') \
  --set-network-port ${DUMP1090_PORT} \
  --set-network-protocol ${DUMP1090_PROTOCOL:-beast} \
  ${@}
