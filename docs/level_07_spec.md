# Level 7 – Desert Wasteland

## Theme

Sandstorms and ruins in a barren desert landscape. High enemy variety with all enemy types present. Introduces shield boss parts that regenerate HP.

## Background

- **Background color:** dark tan (0.12, 0.08, 0.04)
- **Far layer:** `textures/backgrounds/bg_07_far.png` — desert wasteland surface
- **Mid layer:** none (source images exist but not yet stitched)
- **Near layer:** none
- **Decorations:** none

### DALL-E source images

Stored in `sprites/level_07/`:
- `bg_01_mid_1.png`, `bg_01_mid_2.png`, `bg_01_mid_3.png` (mid layer sources, not yet processed)

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.6, 0.5, 0.3) — sand |
| Accent | (0.5, 0.42, 0.22) — dark sand |
| Detail | (0.85, 0.75, 0.4) — gold |
| Name | "desert" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the desert palette.

## Wave structure

Total wave duration: ~86 seconds before boss. All enemy types present including turrets, carriers, and kamikazes in every section.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 10.0 | Scout | 7 | zigzag | 230 | 3 | 1.8 | |
| 14.0 | Diver | 5 | v | 280 | 3 | 9.0 | |
| 18.0 | Gunship | 4 | spread | 150 | 7 | 1.4 | |
| 22.0 | Kamikaze | 5 | swarm | 320 | 3 | 9.0 | |
| 26.0 | Turret | 5 | spread | 0 | 7 | 1.3 | |
| 29.0 | Scout | 10 | string | 240 | 3 | 1.8 | From left |
| 32.0 | Carrier | 2 | spread | 80 | 20 | 1.5 | |
| 32.0 | Scout | 6 | v | 230 | 3 | 2.0 | Simultaneous |
| 35.0 | Diver | 5 | swarm | 300 | 3 | 9.0 | From bottom |
| 38.0 | Gunship | 3 | line | 160 | 8 | 1.3 | |
| 41.0 | Kamikaze | 6 | swarm | 330 | 3 | 9.0 | |
| **44.0** | **Checkpoint** | | | | | | |
| 46.0 | Scout | 8 | circle | 240 | 4 | 1.6 | |
| 50.0 | Diver | 6 | v | 300 | 3 | 9.0 | |
| 54.0 | Kamikaze | 7 | swarm | 340 | 3 | 9.0 | |
| 58.0 | Gunship | 5 | v | 170 | 9 | 1.2 | |
| 62.0 | Turret | 6 | spread | 0 | 8 | 1.1 | |
| 65.0 | Mini-boss | 1 | line | 100 | 40 | 1.0 | |
| 68.0 | Carrier | 2 | spread | 70 | 24 | 1.3 | |
| 68.0 | Kamikaze | 5 | swarm | 340 | 3 | 9.0 | Simultaneous |
| 72.0 | Scout | 12 | string | 250 | 3 | 1.6 | From right |
| 76.0 | Diver | 6 | swarm | 310 | 4 | 9.0 | From bottom |
| 79.0 | Gunship | 4 | spread | 160 | 9 | 1.2 | |
| 79.0 | Scout | 8 | string | 240 | 3 | 1.8 | From left, simultaneous |
| 82.0 | Kamikaze | 8 | swarm | 350 | 3 | 9.0 | |
| **86.0** | **Checkpoint** | | | | | | |

## Boss: Sand Colossus

- **Name:** "Sand Colossus"
- **Phases:** 3
  - Phase 1: 180 HP, attacks: spread + sweep + aimed, bullet speed 310, fire rate 1.2 s
  - Phase 2: 130 HP, attacks: circle + barrage + sweep, bullet speed 340, fire rate 1.0 s
  - Phase 3: 90 HP, attacks: barrage + circle + aimed + sweep, bullet speed 370, fire rate 0.8 s
- **Total HP:** 400
- **Part system:** shield
  - 2 shields at offsets (-50, 0) and (50, 0), 35 HP each
  - Shields regenerate 2 HP/s while alive; must be burst down quickly
  - While any shield alive, boss takes 60% damage
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 6

- Boss total HP 400 + 70 in shields (vs 360 + 75)
- First boss with regenerating parts (shields regen 2 HP/s)
- Scouts start appearing at 4 HP in second half
- Divers at 4 HP in second half
- All enemy types present in both halves
- Mini-boss at 40 HP (vs 35)
- Wave duration increases to ~86 s

## TODO

- [ ] Process mid-layer background from source images
- [ ] Generate DALL-E enemy sprites for level 7 enemy types
- [ ] Generate DALL-E boss sprite for the Sand Colossus
