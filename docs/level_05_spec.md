# Level 5 – Asteroid Field

## Theme

Drifting asteroids in deep space. Heavy kamikaze and diver presence with fast-moving enemies.

## Background

- **Background color:** near black (0.01, 0.01, 0.03)
- **Far layer:** shares level 4's far background (`bg_04_far.png`) via `SHARED_FAR` mapping
- **Mid layer:** `textures/backgrounds/bg_05_mid.png` — asteroid field mid-ground
- **Near layer:** none
- **Decorations:** none

### DALL-E source images

Stored in `sprites/level_05/`:
- `bg_05_mid_1.png`, `bg_05_mid_2.png`, `bg_05_mid_3.png` (mid layer sources)

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.42, 0.32, 0.22) — brown |
| Accent | (0.55, 0.38, 0.22) — tan |
| Detail | (0.85, 0.65, 0.3) — amber |
| Name | "rock" |

## DALL-E sprites

No DALL-E enemy or boss sprites. All enemies use procedural drawing with the rock palette.

## Wave structure

Total wave duration: ~82 seconds before boss.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 10.0 | Scout | 6 | zigzag | 200 | 3 | 2.0 | |
| 15.0 | Diver | 5 | v | 260 | 2 | 9.0 | |
| 20.0 | Kamikaze | 4 | swarm | 300 | 2 | 9.0 | |
| 25.0 | Scout | 8 | line | 220 | 2 | 2.0 | |
| 30.0 | Gunship | 3 | spread | 140 | 6 | 1.5 | |
| 33.0 | Scout | 10 | string | 230 | 2 | 2.0 | From left |
| 35.0 | Diver | 6 | swarm | 270 | 3 | 9.0 | |
| 38.0 | Diver | 4 | swarm | 260 | 2 | 9.0 | From bottom |
| 40.0 | Carrier | 2 | spread | 80 | 16 | 1.6 | |
| 43.0 | Scout | 9 | string | 220 | 3 | 2.0 | From right |
| **46.0** | **Checkpoint** | | | | | | |
| 48.0 | Scout | 7 | circle | 210 | 3 | 1.8 | |
| 53.0 | Kamikaze | 6 | swarm | 310 | 2 | 9.0 | |
| 58.0 | Gunship | 4 | line | 150 | 7 | 1.4 | |
| 63.0 | Diver | 5 | v | 280 | 3 | 9.0 | |
| 65.0 | Mini-boss | 1 | line | 100 | 30 | 1.2 | |
| 68.0 | Carrier | 1 | line | 70 | 20 | 1.5 | |
| 68.0 | Scout | 6 | zigzag | 230 | 2 | 2.0 | Simultaneous |
| 72.0 | Scout | 10 | string | 240 | 3 | 1.8 | From left |
| 75.0 | Kamikaze | 8 | swarm | 320 | 2 | 9.0 | |
| 78.0 | Kamikaze | 5 | swarm | 300 | 2 | 9.0 | From bottom |
| **82.0** | **Checkpoint** | | | | | | |

## Boss: Mining Dreadnought

- **Name:** "Mining Dreadnought"
- **Phases:** 3
  - Phase 1: 140 HP, attacks: spread + aimed, bullet speed 290, fire rate 1.4 s
  - Phase 2: 100 HP, attacks: circle + barrage, bullet speed 310, fire rate 1.2 s
  - Phase 3: 80 HP, attacks: sweep + circle + aimed, bullet speed 340, fire rate 1.0 s
- **Total HP:** 320
- **Part system:** turret
  - 3 turrets at offsets (-45, 15), (0, -25), (45, 15), 25 HP each
  - Turrets fire independently (aimed/spread), no special mechanic beyond being destructible sub-targets
- **Sprite:** none (uses procedural Polygon2D drawing)

## Key differences from Level 4

- First 3-phase boss
- Boss total HP 320 + 75 in turrets
- Shares level 4's far background (space theme continues)
- Heavy kamikaze presence (up to 8 at once)
- Longer wave section (~82 s vs ~80 s)

## TODO

- [ ] Generate DALL-E enemy sprites for level 5 enemy types
- [ ] Generate DALL-E boss sprite for the Mining Dreadnought
