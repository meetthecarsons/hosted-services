#!/bin/sh
# jlesage hook: fires when the automatic disc ripper finishes with a disc
# (the disc ejects right after this, per AUTO_DISC_RIPPER_EJECT=1).
# Args: $1=drive id, $2=disc label, $3=output directory, $4=status (SUCCESS/FAILURE)
DISC_LABEL="$2"
STATUS="$4"

if [ "$STATUS" = "SUCCESS" ]; then
  TITLE="${MAKEMKV_HOST_LABEL}: rip finished, safe to swap disc - ${DISC_LABEL}"
else
  TITLE="${MAKEMKV_HOST_LABEL}: rip FAILED - ${DISC_LABEL}"
fi

wget -q -O /dev/null \
  --header="Title: ${TITLE}" \
  --header="Tags: dvd" \
  --post-data="${DISC_LABEL}: ${STATUS}" \
  "https://ntfy.sh/${NTFY_TOPIC_READY}"
