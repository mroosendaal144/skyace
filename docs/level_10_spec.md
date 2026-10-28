# Level 10 – Cyber Fortress

## Theme

Neon-lit digital fortress — the final level. Maximum enemy density, fastest fire rates, and the ultimate boss with all part types combined.

## Background

- **Background color:** deep purple (0.04, 0.02, 0.08)
- **Far layer:** `textures/backgrounds/bg_10_far.png`
- **Mid layer:** `textures/backgrounds/bg_10_mid.png`
- **Near layer:** `textures/backgrounds/bg_10_near.png`
- **Decorations:** none

### DALL-E source images

No raw DALL-E source images in `sprites/level_10/`. Background textures exist directly in `textures/backgrounds/`.

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.18, 0.12, 0.28) — dark purple |
| Accent | (0.0, 0.7, 0.42) — neon green |
| Detail | (0.0, 1.0, 0.8) — bright cyan-green |
| Name | "cyber" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the cyber palette.

## Wave structure

Total wave duration: ~94 seconds before boss. The longest and most intense wave section. Waves start early and overlap heavily.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 6.0 | Scout | 10 | zigzag | 270 | 4 | 1.4 | Earliest start |
| 9.0 | Gunship | 5 | v | 180 | 10 | 1.1 | |
| 12.0 | Diver | 8 | swarm | 340 | 4 | 9.0 | |
| 15.0 | Kamikaze | 8 | swarm | 380 | 4 | 9.0 | |
| 18.0 | Turret | 7 | spread | 0 | 10 | 1.0 | |
| 21.0 | Scout | 14 | string | 280 | 4 | 1.3 | From left |
| 24.0 | Carrier | 3 | spread | 80 | 30 | 1.2 | |
| 24.0 | Kamikaze | 7 | swarm | 380 | 4 | 9.0 | Simultaneous |
| 27.0 | Gunship | 5 | spread | 190 | 11 | 1.0 | |
| 30.0 | Diver | 8 | v | 350 | 5 | 9.0 | From bottom |
| 33.0 | Scout | 12 | string | 290 | 5 | 1.2 | From right |
| 36.0 | Kamikaze | 10 | swarm | 400 | 4 | 9.0 | |
| 39.0 | Carrier | 2 | line | 70 | 32 | 1.1 | |
| 39.0 | Gunship | 4 | v | 190 | 12 | 0.9 | Simultaneous |
| **42.0** | **Checkpoint** | | | | | | |
| 44.0 | Scout | 12 | circle | 290 | 5 | 1.2 | |
| 47.0 | Diver | 10 | swarm | 360 | 5 | 9.0 | |
| 50.0 | Gunship | 6 | line | 200 | 12 | 0.9 | |
| 53.0 | Kamikaze | 10 | swarm | 400 | 4 | 9.0 | |
| 56.0 | Turret | 8 | spread | 0 | 12 | 0.8 | |
| 59.0 | Mini-boss | 1 | line | 100 | 60 | 0.7 | |
| 62.0 | Carrier | 3 | spread | 70 | 34 | 1.0 | |
| 62.0 | Diver | 8 | swarm | 360 | 5 | 9.0 | Simultaneous |
| 66.0 | Scout | 16 | string | 300 | 5 | 1.1 | From left |
| 70.0 | Kamikaze | 12 | swarm | 410 | 4 | 9.0 | |
| 73.0 | Gunship | 6 | v | 200 | 13 | 0.8 | |
| 73.0 | Scout | 12 | string | 290 | 5 | 1.2 | From right, simultaneous |
| 77.0 | Diver | 10 | swarm | 370 | 5 | 9.0 | From bottom |
| 80.0 | Turret | 10 | spread | 0 | 13 | 0.7 | |
| 80.0 | Kamikaze | 10 | swarm | 400 | 5 | 9.0 | Simultaneous |
| 84.0 | Carrier | 3 | line | 70 | 36 | 0.9 | |
| 84.0 | Gunship | 5 | spread | 200 | 14 | 0.8 | Simultaneous |
| 88.0 | Scout | 14 | string | 300 | 5 | 1.1 | From left |
| 88.0 | Kamikaze | 8 | swarm | 410 | 5 | 9.0 | From right, simultaneous |
| 91.0 | Diver | 10 | v | 380 | 5 | 9.0 | |
| **94.0** | **Checkpoint** | | | | | | |

## Boss: Cyber Overlord

- **Name:** "Cyber Overlord"
- **Phases:** 4
  - Phase 1: 250 HP, attacks: spread + sweep + aimed, bullet speed 350, fire rate 1.0 s
  - Phase 2: 200 HP, attacks: circle + barrage + sweep + aimed, bullet speed 380, fire rate 0.8 s
  - Phase 3: 150 HP, attacks: all types, bullet speed 400, fire rate 0.6 s
  - Phase 4: 100 HP, attacks: all types (enraged), bullet speed 430, fire rate 0.4 s
- **Total HP:** 700
- **Part system:** armor + shield + turret + segment (all types)
  - 2 armor plates at offsets (-45, -20) and (45, -20), 40 HP each
  - 2 shields at offsets (-60, 5) and (60, 5), 45 HP each, regenerate 4 HP/s
  - 2 turrets at offsets (-70, 25) and (70, 25), 35 HP each, aimed + spread attacks
  - 2 segments at offsets (0, 50) and (0, 85), 30 HP each, spread attacks
  - Armor reduces damage to 40%; shields reduce another 50% and regenerate
  - Turrets fire independently; segments provide additional bullet walls
  - When all parts destroyed, boss enters rage mode: 1.5x speed, attacks change to phase 4
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 9

- First 4-phase boss
- Boss total HP 700 + 300 in parts — the largest encounter in the game
- All boss part types present simultaneously
- Shield regen increased to 4 HP/s (vs 3)
- Waves start at t=6 and run to t=94 (~88 s of combat)
- 16 scouts in a single string wave (t=66)
- 12 kamikazes in a single wave (t=70)
- Scouts and kamikazes reach 5 HP
- Gunships reach 14 HP with 0.8 s fire rate
- Mini-boss at 60 HP (vs 50)
- Three background layers (far + mid + near)
- Multiple triple-simultaneous waves in second half

## TODO

- [ ] Generate DALL-E enemy sprites for level 10 enemy types
- [ ] Generate DALL-E boss sprite for the Cyber Overlord
