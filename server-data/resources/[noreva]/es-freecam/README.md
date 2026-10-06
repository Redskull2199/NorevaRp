# ES Freecam

**Author:** ESMODS  
**Discord:** [discord.gg/esmods](https://discord.gg/esmods)  
**Version:** 1.0.0  
**Price:** Free  

Cinematic freecam / camera studio for FiveM.  
---

# English

## What is this script?

`es-freecam` lets players freely move a cinematic camera around their character.  
It is more than a basic freecam:

- Visual filters
- Cinematic letterbox
- Save / load camera positions
- Emote capture with saves
- Modern NUI control panel

Useful for RP servers, photo mode, trailers and content creators.

## Requirements

| Requirement | Required? | Notes |
|---|---|---|
| `ox_lib` | Yes | Notifications + shared init |
| Framework | No | QB / ESX / Qbox / QBus / Standalone |
| Emote menu | No | Improves animation save/load if present |

## Installation

1. Put the resource folder into `resources`. Folder name: **`es-freecam`**
2. Make sure `ox_lib` is running.
3. Add to `server.cfg`:

```cfg
ensure ox_lib
ensure es-freecam
```

4. Edit `config.lua` for your server.
5. Restart the server or run:

```
ensure es-freecam
```

## Framework setup

In `config.lua` → `Framework`:

```lua
Framework = {
    enabled = true,
    -- 'qb' | 'esx' | 'qbox' | 'qbus'
    name = 'qb',
    disableInVehicle = true,
    disableWhenDead = true
}
```

| Value | Meaning |
|---|---|
| `qb` | QBCore (`qb-core`) |
| `esx` | ESX (`es_extended`) |
| `qbox` | Qbox (`qbx_core`) — `qbx` also accepted |
| `qbus` | Legacy QBus (`QBCore:GetObject`) |
| `enabled = false` | Standalone (license-based saves) |

## Language setup

```lua
Locale = 'en'
```

Supported languages:

`tr` `en` `de` `fr` `es` `pt` `ru` `it` `nl` `pl`

## Notification setup

```lua
Notify = {
    -- 'ox' | 'qb' | 'esx' | 'qbox' | 'qbus'
    type = 'ox'
}
```

## Basic controls

| Key | Action |
|---|---|
| `V` (hold) | Toggle freecam |
| `H` | Control panel |
| `W A S D` | Move camera |
| `SHIFT / SPACE` | Down / up |
| `ALT` | Speed boost |
| `Q / E` | Roll |
| `R` | Reset roll |
| Mouse | Look |
| Scroll | FOV |
| `G` | Next filter |
| `F6` | Angle presets |
| `B` | Save position |
| `ESC` | Exit freecam |

Keys can be changed in `config.lua`.

## Features (short)

- Smooth camera
- FOV zoom
- Distance limits (anti-abuse)
- 14 visual filters + intensity
- Letterbox with soft transition
- Grid / HUD / look-at
- Per-player saved shots (citizenid / identifier)
- Relative camera offsets (to the ped)
- Emote save & restore (cylex, rpemotes, dpemotes, etc.)
- Themes: Midnight / Slate / Amber / Mono

## Emote support

When freecam starts, the script tries to capture the current animation.  
Saved positions can also store and replay that emote.

Supported examples:

- `cylex_animmenuv2`
- `rpemotes` / `dpemotes`
- `scully_emotemenu`
- `qb-emotes` / `qs-emotes`
- `rcore_emotes` / `okokAnim`

Full list: `config.lua` → `EmoteProviders`.

## How saves work

- Saved to `saved_cameras.json`
- Split per player ID
- Stores: camera offset, yaw/pitch/roll, FOV, filter, emote
- Filters / cinematic are session-only (reset when freecam closes)
- UI theme preference is persistent (KVP)

## Support

Discord: **discord.gg/esmods**
