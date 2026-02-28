# Host assignments

This file lists which Docker Compose stacks are currently run on each physical host. It is for reference only; there is no automation tied to this document.

```
ds-s-01.lan.internal
  - jellyfin
  - immich
  - arrgh-proton      # VPN & download suite

delamain.lan.internal
  - minecraft-bedrock
```

Update this file whenever you add, remove, or relocate a stack.