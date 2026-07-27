# ARM

[automatic-ripping-machine](https://github.com/automatic-ripping-machine/automatic-ripping-machine),
deployed independently per host that has an optical drive attached
(currently: crafty, DVD only). The stack is host-agnostic — every
host-specific value (drive device nodes, media output path) lives in
`.env`, not in `compose.yaml`. See `planning/disc-ripping-machine.md` in the
outer repo for the full design.

## How it's wired

- `privileged: true` plus `ARM_DEVICE_SR`/`ARM_DEVICE_SG` passthrough (both
  required — MakeMKV needs the generic SCSI device alongside the block
  device; check the right nodes for this host with `lsscsi -g`). The
  container runs its own udev daemon internally and detects disc insertion
  on its own; no host-side udev rules are needed.
- `ARM_UID`/`ARM_GID` are set to `2000`/`2000` (the `apps` service user),
  ARM's own documented env vars for this — not the linuxserver.io-style
  `PUID`/`PGID`, which this image doesn't use.
- `./config` (this directory) mounts to `/etc/arm/config` and holds
  `arm.yaml`/`apprise.yaml`/`abcde.conf`; not yet populated — see the
  work-breakdown issues for configuring disc identification, the MakeMKV
  key, and ntfy notifications.
- Media output lands in `${ARM_MEDIA}`; what that path means varies by
  host (a staging subdirectory on crafty vs. straight into the media
  library on a NAS host) — see the plan doc, not this file, for that
  reasoning.
