# Syncthing

Phone-to-tardis file sync — see `planning/investigate-syncthing.md` in the outer repo for the full design and rationale.

Two synced folders, each mapped to a container path via `.env` (`SYNCTHING_AUDIOBOOKS_DIR`, `SYNCTHING_SMS_DIR`):

- Audiobook downloads (from a phone's Downloads folder)
- SMS/MMS backup archive (exported by SMS Backup & Restore on the phone)

## First-run setup

1. `docker compose up -d`.
2. Open the web GUI at `http://<TS_ADDR>:8384` (only reachable over the tailnet — see `compose.yaml`) and set a GUI username/password (unauthenticated by default on first run).
3. Add the phone as a remote device (its Syncthing device ID, from the phone app), and accept the connection request the phone sends once it's paired.
4. On tardis, add two folders pointed at `/var/syncthing/audiobooks` and `/var/syncthing/sms-backup`, share each with the phone device, and accept the matching folder-share requests on the phone side.
5. On the phone: install Tailscale and join the tailnet, install Syncthing, and point it at tardis's Syncthing over the tailnet (device discovery works automatically once both are tailnet peers, since the local-discovery/relay ports aren't needed for a direct tailnet connection).

Folder IDs and device IDs aren't secrets, but aren't tracked here either — they're generated during pairing, not config-as-code.
