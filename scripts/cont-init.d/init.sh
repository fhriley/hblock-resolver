#!/usr/bin/with-contenv bash

set -eu

if [ "${KRESD_CERT_MANAGED:?}" = 'true' ]; then
	# Generate self-signed certificate if it does not exist
	renew-self-signed-cert
else
	# Wait until the certificate exists
	until [ -f "${KRESD_CERT_CRT_FILE:?}" ] && [ -f "${KRESD_CERT_KEY_FILE:?}" ]; do
		printf '%s\n' 'Checking certificate availability...'
		sleep 3
	done
fi

# Download blacklist zone if it does not exist
if [ ! -f "${KRESD_BLACKLIST_RPZ_FILE:?}" ]; then
	update-blacklist-rpz
fi

for ((ii=1; ii<=KRESD_NUM_INSTANCES; ii++)); do
  mkdir -p /etc/services.d/kresd${ii}
  ln -s /etc/kresd-service/run /etc/services.d/kresd${ii}/run
done
