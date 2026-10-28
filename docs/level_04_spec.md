# Level 4 – Space Shipyard

## Theme

Docking cranes and half-built ships. The transition from Earth to space. Introduces armor boss parts that reduce damage until destroyed.

## Background

- **Background color:** very dark blue (0.02, 0.01, 0.04)
- **Far layer:** `textures/backgrounds/bg_04_far.png` — stitched DALL-E shipyard tiles
- **Mid layer:** `textures/backgrounds/bg_04_mid.png`
- **Near layer:** none
- **Decorations:** none

### DALL-E source images

Stored in `sprites/level_04/`:
- `background_layer_1_1_v1.png`, `background_layer_1_2_v1.png` (far layer sources)
- `background_layer_2_1_v1.png`, `background_layer_2_2_v1.png`, `background_layer_2_3_v1.png` (mid layer sources)

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.5, 0.38, 0.18) — bronze |
| Accent | (0.7, 0.5, 0.22) — gold |
| Detail | (1.0, 0.9, 0.3) — bright yellow |
| Name | "industrial" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the industrial palette.

## Wave structure

Total wave duration: ~80 seconds before boss.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 10.0 | Scout | 6 | line | 180 | 2 | 2.2 | |
| 15.0 | Gunship | 3 | v | 130 | 5 | 1.8 | |
| 21.0 | Scout | 4 | zigzag | 200 | 3 | 2.0 | |
| 26.0 | Diver | 5 | swarm | 240 | 2 | 9.0 | |
| 31.0 | Carrier | 1 | line | 70 | 14 | 1.8 | |
| 31.0 | Scout | 5 | v | 190 | 2 | 2.5 | Simultaneous |
| 34.0 | Scout | 9 | string | 210 | 2 | 2.0 | From right |
| 37.0 | Turret | 4 | spread | 0 | 5 | 1.5 | |
| 40.0 | Diver | 4 | spread | 250 | 2 | 9.0 | From bottom |
| **43.0** | **Checkpoint** | | | | | | |
| 45.0 | Gunship | 4 | line | 140 | 6 | 1.5 | |
| 51.0 | Scout | 8 | circle | 200 | 2 | 2.0 | |
| 57.0 | Kamikaze | 5 | swarm | 280 | 2 | 9.0 | |
| 62.0 | Carrier | 2 | spread | 80 | 15 | 1.6 | |
| 65.0 | Mini-boss | 1 | line | 100 | 26 | 1.2 | |
| 68.0 | Diver | 6 | v | 260 | 3 | 9.0 | |
| 71.0 | Scout | 10 | string | 220 | 2 | 2.0 | From left |
| 74.0 | Gunship | 3 | spread | 120 | 7 | 1.4 | |
| 74.0 | Scout | 8 | string | 200 | 3 | 2.2 | From right, simultaneous |
| 77.0 | Kamikaze | 4 | swarm | 280 | 2 | 9.0 | From bottom |
| **80.0** | **Checkpoint** | | | | | | |

## Boss: Shipyard Mech

- **Name:** "Shipyard Mech"
- **Phases:** 2
  - Phase 1: 150 HP, attacks: spread + sweep, bullet speed 280, fire rate 1.4 s
  - Phase 2: 100 HP, attacks: circle + barrage + aimed, bullet speed 310, fire rate 1.1 s
- **Total HP:** 250
- **Part system:** armor
  - 2 armor plates at offsets (-35, -10) and (35, -10), 30 HP each
  - While armor alive, boss takes only 40% damage; after all destroyed, takes 150% damage
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 3

- First boss with armor part system (damage reduction)
- Boss total HP 250 + 60 in armor (vs 200 + 50)
- Enemies start appearing with 3 HP
- Kamikaze enemies now have 2 HP
- Two mid-layer background (shipyard has far + mid)

## TODO

- [ ] Generate DALL-E enemy sprites for level 4 enemy types
- [ ] Generate DALL-E boss sprite for the Shipyard Mech
