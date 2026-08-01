# makemkv

[jlesage/docker-makemkv](https://github.com/jlesage/docker-makemkv) running
in automatic-disc-ripper mode: insert a disc, it rips every title above
`MAKEMKV_MIN_TITLE_LENGTH` to `/output/<disc label>/`, ejects, and waits for
the next one. No identification, renaming, or transcoding happens here —
this stack is deliberately rip-only; those steps live downstream.

Each disc gets its own output folder (`/output/DISC_LABEL/`, or
`DISC_LABEL-XXXXXX` if that name is already taken), so two discs never write
into the same directory.

`/output` only ever holds discs that are still ripping, or that failed.
`./hooks/disc_rip_terminated.sh` moves a disc's folder from `/output` to
`/completed` the moment MakeMKV reports success - so `/completed` is always
safe for [disc-matcher](https://github.com/rcarson/disc-matcher) to read
from without needing to guess whether a rip is still in progress. A failed
rip is left in `/output` rather than promoted.

Files are named `<disc label>-<track>.mkv`. MakeMKV itself only produces the
track number (`makemkv-config` sets `app_DefaultOutputFileName = "{AM2}"` in
`/config/.MakeMKV/settings.conf`) - the `<disc label>-` prefix is added by
`disc_rip_terminated.sh` during the move to `/completed`, using the disc
label jlesage itself passes to the hook. This is deliberate: MakeMKV's own
`{NAME1}` template token reads a disc-internal metadata field that's empty
on some discs (confirmed on this household's "My Life is Murder" S2 set),
silently dropping the prefix if relied on directly.

## Web UI

`http://<host>:${MAKEMKV_PORT}` (noVNC) - shows drive/rip status.

## Devices

`MAKEMKV_DEVICE_SR`/`MAKEMKV_DEVICE_SG` must point at the same physical
drive - the block device (`/dev/sr0`) and its SCSI generic sibling
(`/dev/sg0`), which MakeMKV needs for direct disc access. Confirm the pairing
with `udevadm info --query=all --name=/dev/sr0` (look at `ID_SERIAL`) before
assuming device numbering matches across hosts or reboots.

## Registration key

Runs on MakeMKV's rotating beta key by default (`MAKEMKV_KEY=BETA`). Restart
the container if ripping starts failing with a key-expired error.

## Notifications

`./hooks/disc_rip_started.sh` and `./hooks/disc_rip_terminated.sh` post to
the `NTFY_TOPIC_READY` topic (via jlesage's `/config/hooks/` mechanism) when
a disc starts and finishes ripping, so whoever's swapping discs knows when
it's safe to open the drive. Both messages include the disc label. A failed
rip posts to the same topic with a `FAILED` title rather than a separate
alerts topic — this host doesn't have the homelab alerting kit's `alerts`/
`info` topics deployed yet.
