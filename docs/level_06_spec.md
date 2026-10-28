# Level 6 – Lava Planet

## Theme

Lava bursts and fire geysers on a volcanic world. Intense waves with high enemy HP and fast fire rates.

## Background

- **Background color:** dark red (0.08, 0.03, 0.02)
- **Far layer:** `textures/backgrounds/bg_06_far.png` — lava planet surface
- **Mid layer:** none (source images exist but not yet stitched)
- **Near layer:** none
- **Decorations:** none

### DALL-E source images

Stored in `sprites/level_06/`:
- `bg_06_mid_1.png`, `bg_06_mid_2.png`, `bg_06_mid_3.png` (mid layer sources, not yet processed)

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.6, 0.15, 0.08) — dark red |
| Accent | (0.9, 0.35, 0.08) — orange |
| Detail | (1.0, 0.75, 0.15) — yellow-gold |
| Name | "lava" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the lava palette.

## Wave structure

Total wave duration: ~84 seconds before boss. Opens with gunships instead of scouts.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 10.0 | Gunship | 3 | spread | 140 | 6 | 1.6 | |
| 15.0 | Diver | 5 | v | 270 | 3 | 9.0 | |
| 20.0 | Scout | 7 | zigzag | 220 | 3 | 1.8 | |
| 25.0 | Kamikaze | 5 | swarm | 310 | 2 | 9.0 | |
| 28.0 | Scout | 9 | string | 230 | 3 | 1.8 | From left |
| 30.0 | Turret | 5 | spread | 0 | 6 | 1.4 | |
| 33.0 | Diver | 4 | swarm | 290 | 3 | 9.0 | From bottom |
| 35.0 | Carrier | 2 | spread | 80 | 18 | 1.5 | |
| 35.0 | Diver | 4 | swarm | 280 | 3 | 9.0 | Simultaneous |
| 39.0 | Scout | 10 | string | 220 | 3 | 2.0 | From right |
| 42.0 | Gunship | 4 | line | 150 | 7 | 1.4 | |
| **48.0** | **Checkpoint** | | | | | | |
| 50.0 | Scout | 8 | circle | 230 | 3 | 1.6 | |
| 55.0 | Kamikaze | 6 | swarm | 320 | 3 | 9.0 | |
| 60.0 | Gunship | 4 | v | 160 | 8 | 1.3 | |
| 65.0 | Diver | 6 | line | 290 | 3 | 9.0 | |
| 67.0 | Mini-boss | 1 | line | 100 | 35 | 1.1 | |
| 70.0 | Carrier | 2 | spread | 70 | 22 | 1.4 | |
| 70.0 | Kamikaze | 4 | swarm | 330 | 2 | 9.0 | Simultaneous |
| 73.0 | Scout | 10 | string | 240 | 3 | 1.8 | From left |
| 77.0 | Turret | 6 | spread | 0 | 7 | 1.2 | |
| 77.0 | Kamikaze | 5 | swarm | 320 | 2 | 9.0 | From bottom, simultaneous |
| 80.0 | Scout | 8 | string | 230 | 3 | 2.0 | From right |
| **84.0** | **Checkpoint** | | | | | | |

## Boss: Magma Serpent

- **Name:** "Magma Serpent"
- **Phases:** 3
  - Phase 1: 160 HP, attacks: sweep + aimed, bullet speed 300, fire rate 1.3 s
  - Phase 2: 120 HP, attacks: circle + barrage, bullet speed 330, fire rate 1.1 s
  - Phase 3: 80 HP, attacks: sweep + circle + barrage, bullet speed 360, fire rate 0.9 s
- **Total HP:** 360
- **Part system:** segment
  - 3 segments at offsets (0, 50), (-15, 80), (15, 110)
  - HP: 30, 25, 20; first two have shooting attacks (spread, aimed)
  - No special mechanic beyond destructible sub-targets
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 5

- Boss total HP 360 + 75 in segments (vs 320 + 75)
- Kamikaze enemies at 3 HP for the first time
- Wave opens with gunships instead of scouts
- Carrier HP increases to 18–22
- Multiple simultaneous double-waves

## TODO

- [ ] Process mid-layer background from source images
- [ ] Generate DALL-E enemy sprites for level 6 enemy types
- [ ] Generate DALL-E boss sprite for the Magma Serpent
