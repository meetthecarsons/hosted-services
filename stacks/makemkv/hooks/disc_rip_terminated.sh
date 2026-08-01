#!/bin/sh
# jlesage hook: fires when the automatic disc ripper finishes with a disc,
# once every title file is fully written and closed (the disc ejects right
# after this, per AUTO_DISC_RIPPER_EJECT=1).
# Args: $1=drive id, $2=disc label, $3=output directory, $4=status (SUCCESS/FAILURE)
DISC_LABEL="$2"
OUTPUT_DIR="$3"
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

# Only a fully successful, fully-closed rip is safe for disc-matcher to see.
# Moving it out of /output (rather than leaving it for the matcher to guess
# at via mtimes or file counts) means the matcher never has to tell a
# mid-rip folder apart from a finished one - it only ever looks in
# /completed. A failed rip is left in /output for manual inspection instead
# of being promoted.
if [ "$STATUS" = "SUCCESS" ]; then
  mv "$OUTPUT_DIR" "/completed/$(basename "$OUTPUT_DIR")"
fi
