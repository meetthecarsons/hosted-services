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
- `arm.yaml` is rendered at `up` by the `arm-config` service (same pattern
  as `monitoring`'s `ntfy-bridge-config`): it substitutes `ARM_NAME`,
  `MAKEMKV_PERMA_KEY`, and `OMDB_API_KEY` from `.env` into
  `config/arm.yaml.tpl` and writes the result to a named volume, which
  `arm` mounts at `/etc/arm/config`. This means the config-as-code template
  is the source of truth — any edits made through ARM's web UI to
  `arm.yaml` itself get overwritten on the next `docker compose up -d`
  (recreate the volume with `docker volume rm arm_arm-config` if it ever
  needs a clean re-render). `apprise.yaml`/`abcde.conf` aren't set up yet —
  see the work-breakdown issues for ntfy notifications.
- `MAKEMKV_PERMA_KEY` can be left empty — MakeMKV then runs on its
  rotating free beta key instead of a purchased one.
- Media output lands in `${ARM_MEDIA}`; what that path means varies by
  host (a staging subdirectory on crafty vs. straight into the media
  library on a NAS host) — see the plan doc, not this file, for that
  reasoning.
