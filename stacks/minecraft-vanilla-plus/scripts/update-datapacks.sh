#!/usr/bin/env bash
# Fetches the pack set below from Vanilla Tweaks for this server's MC
# version, replaces the previously-installed set in DATA_DIR/world/datapacks
# with it, and restarts the container so the change takes effect. Vanilla
# Tweaks has no static per-pack URLs -- packs are selected and zipped on
# demand via its API (https://vanillatweaks.net/assets/server/zipdatapacks.php),
# which is why this can't just be a list of curl'd URLs.
#
# Run this on the host the stack is deployed to (it reads DATA_DIR and
# VERSION from the sibling .env). Edit the pack list below and re-run to
# change the set -- there's no separate config file.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="$script_dir/../.env"

if [ ! -f "$env_file" ]; then
  echo "missing $env_file — deploy the stack first (make deploy SERVICE=minecraft-vanilla-plus)" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$env_file"

packs_json=$(jq -nc '{
  "Decorative/Cosmetic": ["armor statues","custom nether portals","mini blocks","more mob heads","name colors","player head drops","silence mobs","wandering trades hermit edition"],
  "Convenience": ["double shulker shells","dragon drops","fast leaf decay","more effective tools","multiplayer sleep","painting picker","timber","wood stripper"],
  "Gameplay Changes": ["anti enderman grief","armored elytra","classic fishing loot","graves","husks drop sand","xp bottling"],
  "Informative": ["afk display","coordinates hud","durability ping","nether portal coords","spawning spheres","track raw statistics","track statistics","villager workstation highlights","wandering trader announcements"],
  "Admin Tools": ["kill empty boats"],
  "Teleport Commands": ["tpa"]
}')

datapacks_dir="$DATA_DIR/world/datapacks"
manifest="$datapacks_dir/.vanillatweaks-manifest"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "Requesting datapack bundle for MC $VERSION..."
response=$(curl -sf -X POST "https://vanillatweaks.net/assets/server/zipdatapacks.php" \
  --data-urlencode "packs=$packs_json" \
  --data-urlencode "version=$VERSION")

if [ "$(echo "$response" | jq -r '.status')" != "success" ]; then
  echo "Vanilla Tweaks API request failed: $response" >&2
  exit 1
fi

link=$(echo "$response" | jq -r '.link')
curl -sf "https://vanillatweaks.net${link}" -o "$tmp_dir/bundle.zip"
unzip -q "$tmp_dir/bundle.zip" -d "$tmp_dir/packs"

mkdir -p "$datapacks_dir"

if [ -f "$manifest" ]; then
  echo "Removing previously-installed pack set..."
  while IFS= read -r name; do
    [ -n "$name" ] && rm -f "${datapacks_dir:?}/$name"
  done <"$manifest"
fi

pack_count=$(find "$tmp_dir/packs" -maxdepth 1 -name '*.zip' | wc -l)
echo "Installing $pack_count datapacks..."
find "$tmp_dir/packs" -maxdepth 1 -name '*.zip' -exec cp {} "$datapacks_dir/" \;
find "$tmp_dir/packs" -maxdepth 1 -name '*.zip' -printf '%f\n' >"$manifest"

echo "Restarting minecraft-vanilla-plus to apply..."
(cd "$script_dir/.." && docker compose restart minecraft)

echo "Done."
