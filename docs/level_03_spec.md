# Level 3 – Capital City

## Theme

Skyscrapers and missile batteries. Introduces multi-phase bosses with a part system (wing) and higher enemy density with simultaneous wave spawns.

## Background

- **Background color:** gray-blue (0.35, 0.38, 0.40)
- **Far layer:** `textures/backgrounds/bg_03_far.png` — stitched DALL-E capital city tiles
- **Mid layer:** none
- **Near layer:** none
- **Decorations:** none

### DALL-E source images

Stored in `sprites/level_03/`:
- `background_1_v1.png`
- `background_2_v1.png`
- `background_3_v1.png`

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.28, 0.28, 0.32) — dark gray |
| Accent | (0.18, 0.18, 0.22) — charcoal |
| Detail | (0.9, 0.25, 0.2) — red |
| Name | "city" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the city palette.

## Wave structure

Total wave duration: ~80 seconds before boss.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 10.0 | Scout | 5 | v | 170 | 2 | 2.5 | |
| 15.0 | Gunship | 2 | spread | 120 | 4 | 2.0 | |
| 21.0 | Diver | 4 | swarm | 230 | 2 | 9.0 | |
| 26.0 | Turret | 4 | spread | 0 | 4 | 1.8 | |
| 32.0 | Scout | 7 | zigzag | 190 | 2 | 2.2 | |
| 35.0 | Scout | 9 | string | 200 | 2 | 2.0 | From left |
| 38.0 | Carrier | 1 | line | 80 | 10 | 2.0 | |
| 38.0 | Scout | 4 | v | 180 | 1 | 2.5 | Simultaneous with carrier |
| 41.0 | Diver | 4 | swarm | 240 | 2 | 9.0 | From bottom |
| **44.0** | **Checkpoint** | | | | | | |
| 46.0 | Gunship | 3 | line | 130 | 5 | 1.6 | |
| 52.0 | Diver | 5 | v | 250 | 2 | 9.0 | |
| 57.0 | Kamikaze | 4 | swarm | 260 | 1 | 9.0 | |
| 62.0 | Turret | 5 | spread | 0 | 5 | 1.5 | |
| 65.0 | Mini-boss | 1 | line | 100 | 22 | 1.3 | |
| 68.0 | Carrier | 2 | spread | 90 | 12 | 1.8 | |
| 71.0 | Scout | 10 | string | 210 | 2 | 2.0 | From right |
| 74.0 | Scout | 8 | line | 200 | 2 | 2.0 | |
| 74.0 | Kamikaze | 3 | swarm | 260 | 1 | 9.0 | From left, simultaneous |
| 77.0 | Scout | 8 | string | 190 | 2 | 2.2 | From left |
| **80.0** | **Checkpoint** | | | | | | |

## Boss: Flying Fortress

- **Name:** "Flying Fortress"
- **Phases:** 2
  - Phase 1: 120 HP, attacks: spread + aimed + barrage, bullet speed 270, fire rate 1.5 s
  - Phase 2: 80 HP, attacks: circle + sweep + aimed, bullet speed 300, fire rate 1.2 s
- **Total HP:** 200
- **Part system:** wing
  - 2 wings at offsets (-60, 10) and (60, 10), 25 HP each, fire rate 2.0 s, aimed attacks
  - When all wings destroyed, boss speed increases 1.4x
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 2

- First boss with a part system (destructible wings)
- First 2-phase boss with 3 attack types per phase
- Boss total HP increases from 160 to 200 plus 50 HP in wing parts
- Mini-boss at 22 HP (vs 18)
- Simultaneous wave spawns at t=38 and t=74
- Carrier enemies appear for the first time

## TODO

- [ ] Generate DALL-E enemy sprites for level 3 enemy types
- [ ] Generate DALL-E boss sprite for the Flying Fortress
