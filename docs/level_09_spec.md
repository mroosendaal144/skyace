# Level 9 – Deep Ocean Trench

## Theme

Bioluminescent deep-sea environment. The penultimate level with relentless enemy pressure and a boss with shield + segment parts.

## Background

- **Background color:** deep aqua (0.02, 0.06, 0.08)
- **Far layer:** `textures/backgrounds/bg_09_far.png`
- **Mid layer:** `textures/backgrounds/bg_09_mid.png`
- **Near layer:** `textures/backgrounds/bg_09_near.png`
- **Decorations:** none

### DALL-E source images

No raw DALL-E source images in `sprites/level_09/`. Background textures exist directly in `textures/backgrounds/`.

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.12, 0.4, 0.42) — teal |
| Accent | (0.18, 0.52, 0.48) — aquamarine |
| Detail | (0.35, 0.85, 0.9) — bright cyan |
| Name | "aqua" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the aqua palette.

## Wave structure

Total wave duration: ~90 seconds before boss. Relentless pacing with minimal gaps between waves.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 8.0 | Scout | 8 | zigzag | 250 | 4 | 1.5 | Earlier start |
| 11.0 | Gunship | 5 | v | 170 | 9 | 1.2 | |
| 14.0 | Diver | 7 | swarm | 320 | 4 | 9.0 | |
| 17.0 | Kamikaze | 7 | swarm | 360 | 3 | 9.0 | |
| 20.0 | Turret | 6 | spread | 0 | 9 | 1.1 | |
| 23.0 | Scout | 12 | string | 260 | 4 | 1.4 | From left |
| 26.0 | Carrier | 2 | spread | 80 | 26 | 1.3 | |
| 26.0 | Kamikaze | 6 | swarm | 360 | 3 | 9.0 | Simultaneous |
| 29.0 | Gunship | 4 | spread | 180 | 10 | 1.1 | |
| 32.0 | Diver | 8 | v | 330 | 4 | 9.0 | From bottom |
| 35.0 | Scout | 10 | string | 270 | 4 | 1.4 | From right |
| 38.0 | Kamikaze | 8 | swarm | 370 | 3 | 9.0 | |
| 41.0 | Carrier | 2 | line | 70 | 28 | 1.2 | |
| **44.0** | **Checkpoint** | | | | | | |
| 46.0 | Scout | 10 | circle | 270 | 5 | 1.3 | |
| 49.0 | Diver | 8 | swarm | 340 | 4 | 9.0 | |
| 52.0 | Gunship | 6 | line | 190 | 11 | 1.0 | |
| 56.0 | Kamikaze | 9 | swarm | 380 | 4 | 9.0 | |
| 59.0 | Turret | 8 | spread | 0 | 10 | 0.9 | |
| 62.0 | Mini-boss | 1 | line | 100 | 50 | 0.8 | |
| 65.0 | Carrier | 3 | spread | 70 | 30 | 1.1 | |
| 65.0 | Diver | 6 | swarm | 340 | 4 | 9.0 | Simultaneous |
| 69.0 | Scout | 14 | string | 280 | 4 | 1.3 | From left |
| 73.0 | Kamikaze | 10 | swarm | 390 | 4 | 9.0 | |
| 76.0 | Gunship | 5 | v | 190 | 12 | 0.9 | |
| 76.0 | Scout | 10 | string | 270 | 4 | 1.4 | From right, simultaneous |
| 80.0 | Diver | 8 | swarm | 350 | 5 | 9.0 | From bottom |
| 83.0 | Turret | 8 | spread | 0 | 11 | 0.8 | |
| 83.0 | Kamikaze | 8 | swarm | 380 | 4 | 9.0 | Simultaneous |
| 87.0 | Carrier | 2 | spread | 70 | 32 | 1.0 | |
| **90.0** | **Checkpoint** | | | | | | |

## Boss: Leviathan

- **Name:** "Leviathan"
- **Phases:** 3
  - Phase 1: 220 HP, attacks: spread + sweep + aimed + barrage, bullet speed 340, fire rate 1.0 s
  - Phase 2: 160 HP, attacks: circle + barrage + sweep + aimed, bullet speed 370, fire rate 0.8 s
  - Phase 3: 120 HP, attacks: all types, bullet speed 400, fire rate 0.6 s
- **Total HP:** 500
- **Part system:** shield + segment (combined)
  - 2 shields at offsets (-55, 5) and (55, 5), 40 HP each, regenerate 3 HP/s
  - 3 segments at offsets (0, 45), (-20, 75), (20, 105), HP: 35, 30, 25
  - Shields reduce incoming damage to 50% while alive and regenerate
  - Segments fire independently (aimed + spread)
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 8

- Boss total HP 500 + 170 in parts (vs 450 + 130)
- Shields regenerate 3 HP/s (vs 0 in level 8's armor)
- Waves start at t=8 instead of t=10
- Scouts and divers at 5 HP in second half
- Mini-boss at 50 HP (vs 45)
- 14 scouts in a single string wave (t=69)
- Three background layers (far + mid + near)
- Kamikazes at 4 HP in second half

## TODO

- [ ] Generate DALL-E enemy sprites for level 9 enemy types
- [ ] Generate DALL-E boss sprite for the Leviathan
