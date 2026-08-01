#!/bin/sh
# jlesage hook: fires when the automatic disc ripper starts ripping a disc.
# Args: $1=drive id, $2=disc label, $3=output directory
DISC_LABEL="$2"

wget -q -O /dev/null \
  --header="Title: ${MAKEMKV_HOST_LABEL}: ripping started - ${DISC_LABEL}" \
  --header="Tags: dvd" \
  --post-data="Ripping ${DISC_LABEL}" \
  "https://ntfy.sh/${NTFY_TOPIC_READY}"
