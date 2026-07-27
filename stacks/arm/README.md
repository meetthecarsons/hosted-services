# ARM

[automatic-ripping-machine](https://github.com/automatic-ripping-machine/automatic-ripping-machine),
deployed independently per host that has an optical drive attached
(currently: crafty, DVD only). The stack is host-agnostic — the
host-specific value that varies (media output path) lives in `.env`, not
in `compose.yaml`. See `planning/disc-ripping-machine.md` in the outer repo
for the full design.

## How it's wired

- `privileged: true` grants the container every host device (there's no
  glob/wildcard syntax for Docker's `devices:` list, so this is simpler
  than enumerating this host's `/dev/sr*`+`/dev/sg*` pair — MakeMKV needs
  both the block device and its matching generic SCSI device). Also
  required anyway for ARM's internal udev daemon to see disc-insert
  events; the container detects insertion on its own, no host-side udev
  rules needed.
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
