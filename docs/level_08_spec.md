# Level 8 – Space Armada

## Theme

Fleet of warships in orbit above Earth. Dense formations and coordinated attacks. The boss introduces combined part types (armor + turrets).

## Background

- **Background color:** deep space blue (0.01, 0.02, 0.06)
- **Far layer:** shares level 4's far background (`bg_04_far.png`) via `SHARED_FAR` mapping
- **Mid layer:** `textures/backgrounds/bg_08_mid.png` (source exists but not yet processed)
- **Near layer:** `textures/backgrounds/bg_08_near.png` (source exists but not yet processed)
- **Decorations:** none

### DALL-E source images

Stored in `sprites/level_08/`:
- `bg_08_far.png` (exists but unused — far layer shared from level 4)
- `bg_08_mid.png` (not yet processed into final texture)
- `bg_08_near.png` (not yet processed into final texture)

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.32, 0.38, 0.52) — steel blue |
| Accent | (0.22, 0.28, 0.42) — dark blue |
| Detail | (0.45, 0.72, 1.0) — bright blue |
| Name | "fleet" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the fleet palette.

## Wave structure

Total wave duration: ~88 seconds before boss. Tight wave spacing with heavy overlap.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 10.0 | Scout | 8 | line | 240 | 3 | 1.6 | |
| 13.0 | Gunship | 4 | v | 160 | 8 | 1.3 | |
| 17.0 | Diver | 6 | swarm | 300 | 3 | 9.0 | |
| 20.0 | Kamikaze | 6 | swarm | 340 | 3 | 9.0 | |
| 23.0 | Scout | 10 | string | 250 | 3 | 1.6 | From right |
| 26.0 | Turret | 6 | spread | 0 | 8 | 1.2 | |
| 29.0 | Carrier | 2 | spread | 80 | 22 | 1.4 | |
| 29.0 | Diver | 5 | v | 310 | 3 | 9.0 | Simultaneous |
| 32.0 | Gunship | 3 | spread | 170 | 9 | 1.2 | |
| 35.0 | Scout | 12 | string | 260 | 3 | 1.6 | From left |
| 38.0 | Kamikaze | 7 | swarm | 350 | 3 | 9.0 | |
| 41.0 | Carrier | 1 | line | 70 | 26 | 1.3 | |
| **44.0** | **Checkpoint** | | | | | | |
| 46.0 | Scout | 10 | circle | 260 | 4 | 1.4 | |
| 50.0 | Diver | 7 | swarm | 320 | 4 | 9.0 | |
| 54.0 | Gunship | 5 | line | 180 | 10 | 1.1 | |
| 58.0 | Kamikaze | 8 | swarm | 360 | 3 | 9.0 | |
| 61.0 | Turret | 7 | spread | 0 | 9 | 1.0 | |
| 64.0 | Mini-boss | 1 | line | 100 | 45 | 0.9 | |
| 67.0 | Carrier | 3 | line | 70 | 26 | 1.2 | |
| 67.0 | Kamikaze | 6 | swarm | 350 | 3 | 9.0 | Simultaneous |
| 71.0 | Scout | 12 | string | 270 | 4 | 1.4 | From right |
| 75.0 | Diver | 8 | swarm | 330 | 4 | 9.0 | From bottom |
| 78.0 | Gunship | 5 | v | 180 | 10 | 1.0 | |
| 78.0 | Scout | 10 | string | 260 | 3 | 1.6 | From left, simultaneous |
| 82.0 | Kamikaze | 10 | swarm | 370 | 3 | 9.0 | |
| 85.0 | Turret | 6 | spread | 0 | 10 | 0.9 | |
| **88.0** | **Checkpoint** | | | | | | |

## Boss: Fleet Commander

- **Name:** "Fleet Commander"
- **Phases:** 3
  - Phase 1: 200 HP, attacks: spread + sweep + aimed, bullet speed 320, fire rate 1.1 s
  - Phase 2: 150 HP, attacks: circle + barrage + aimed, bullet speed 350, fire rate 0.9 s
  - Phase 3: 100 HP, attacks: barrage + circle + sweep + aimed, bullet speed 380, fire rate 0.7 s
- **Total HP:** 450
- **Part system:** armor + turret (combined)
  - 2 armor plates at offsets (-40, -15) and (40, -15), 35 HP each
  - 2 turrets at offsets (-55, 20) and (55, 20), 30 HP each, aimed attacks
  - Boss takes 50% damage while any armor plate is alive
  - Turrets provide suppressive fire; when destroyed, boss gains 1.2x speed
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 7

- First boss with combined part types (armor + turret)
- Boss total HP 450 + 130 in parts (vs 400 + 70)
- Three carriers at once (t=67)
- Enemies at 4 HP throughout second half
- Turrets reach 10 HP with 0.9 s fire rate
- Mini-boss at 45 HP (vs 40)
- 10 kamikazes in a single wave (t=82)
- Shares level 4's far background (space theme)

## TODO

- [ ] Process mid-layer background from source images
- [ ] Process near-layer background from source images
- [ ] Generate DALL-E enemy sprites for level 8 enemy types
- [ ] Generate DALL-E boss sprite for the Fleet Commander
