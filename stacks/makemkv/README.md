# makemkv

[jlesage/docker-makemkv](https://github.com/jlesage/docker-makemkv) running
in automatic-disc-ripper mode: insert a disc, it rips every title above
`MAKEMKV_MIN_TITLE_LENGTH` to `/output/<disc label>/`, ejects, and waits for
the next one. No identification, renaming, or transcoding happens here —
this stack is deliberately rip-only; those steps live downstream.

Each disc gets its own output folder (`/output/DISC_LABEL/`, or
`DISC_LABEL-XXXXXX` if that name is already taken), so two discs never write
into the same directory.

## Web UI

`http://<host>:${MAKEMKV_PORT}` (noVNC) - shows drive/rip status and lets you
adjust MakeMKV's own settings (e.g. `app_DefaultOutputFileName` in
`/config/.MakeMKV/settings.conf`, if per-title naming inside a disc's folder
ever needs to change from MakeMKV's default).

## Devices

`MAKEMKV_DEVICE_SR`/`MAKEMKV_DEVICE_SG` must point at the same physical
drive - the block device (`/dev/sr0`) and its SCSI generic sibling
(`/dev/sg0`), which MakeMKV needs for direct disc access. Confirm the pairing
with `udevadm info --query=all --name=/dev/sr0` (look at `ID_SERIAL`) before
assuming device numbering matches across hosts or reboots.

## Registration key

Runs on MakeMKV's rotating beta key by default (`MAKEMKV_KEY=BETA`). Restart
the container if ripping starts failing with a key-expired error.
