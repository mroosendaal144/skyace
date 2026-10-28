# Level 1 – Ocean

## Theme

Open sea with warships and seaplanes. The first level introduces basic enemy types and teaches the player the core mechanics.

## Background

- **Background color:** medium blue (0.1, 0.45, 0.65)
- **Far layer:** `textures/backgrounds/bg_01_far.png` — ocean surface
- **Mid layer:** none (level 1 skips mid layer in starfield.gd)
- **Near layer:** none (`bg_01_near.png` does not exist, foreground.gd handles this gracefully)
- **Decorations:** ocean-themed island and ship textures in `textures/decorations/` at z_index 1. Includes 15 island variants (large mountain, volcano, lagoon, atoll, etc.), 3 left-edge cliffs/beaches, and 3 right-edge cliffs/beaches. Note: decoration spawning is currently inactive (`_load_textures()` not called in `_ready()`).

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.35, 0.45, 0.55) — blue-gray |
| Accent | (0.5, 0.6, 0.7) — lighter blue-gray |
| Detail | (0.75, 0.85, 0.95) — pale blue |
| Name | "ocean" |

## DALL-E sprites

Level 1 uses DALL-E-generated alien aquatic enemy sprites instead of procedural drawing. Sprites are loaded at runtime via `GameManager.load_texture()` and rendered as Sprite2D children at 1.3× scale.

### Enemy sprites

| Enemy type | Sprite file | Size | Notes |
| --- | --- | --- | --- |
| Scout | `sprites/level_01/scout.png` | 40×40 px | Also used for diver and kamikaze |
| Gunship | `sprites/level_01/gunship.png` | 56×56 px | |
| Carrier | `sprites/level_01/heavy.png` | 64×64 px | Also used for mini_boss |
| Turret | (none) | — | Uses procedural drawing |

**Source DALL-E images** (pre-processing originals):
- `sprites/level_01/enemy_scout_level_1.png`
- `sprites/level_01/enemy_gunship_level_1.png`
- `sprites/level_01/enemy_heavy_level_1.png`

### Boss sprite

- **File:** `sprites/level_01/boss_processed.png` (200×133 px)
- **Source:** `sprites/level_01/boss.png` (1536×1024 px DALL-E output)
- **Processing:** the boss sprite required special handling because flood-fill background removal leaked through narrow gaps between tentacles. Solution: scale the image DOWN first (to 200×133 via Lanczos interpolation, which blends gap edges together), THEN run flood-fill background removal (threshold 0.10). This "scale-first" approach prevents fill leakage through thin structural gaps.
- **Collision shape:** resized from default 80×50 to 160×100 to match the sprite
- **Polygon2D children:** all hidden when sprite is loaded (Hull, Core, Eye, LeftCannon, RightCannon)

## Wave structure

Total wave duration: ~74 seconds before boss.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 6.0 | Turret | 1 | line | 0 | 3 | 2.0 | x=560 |
| 8.0 | Turret | 1 | line | 0 | 3 | 2.2 | x=140 |
| 10.0 | Scout | 4 | line | 140 | 1 | 3.5 | |
| 15.0 | Scout | 3 | v | 150 | 1 | 3.0 | |
| 21.0 | Scout | 5 | line | 160 | 1 | 3.0 | |
| 27.0 | Diver | 3 | spread | 200 | 1 | 9.0 | |
| 28.0 | Turret | 2 | line | 0 | 4 | 1.8 | x=280, 440 |
| 30.0 | Scout | 8 | string | 160 | 1 | 2.5 | From left |
| 33.0 | Scout | 4 | zigzag | 150 | 1 | 2.8 | |
| 36.0 | Diver | 3 | swarm | 210 | 1 | 9.0 | From bottom |
| **38.0** | **Checkpoint** | | | | | | |
| 40.0 | Scout | 5 | v | 170 | 2 | 2.5 | |
| 46.0 | Gunship | 2 | spread | 100 | 3 | 2.0 | |
| 50.0 | Turret | 2 | line | 0 | 3 | 2.0 | x=120, 600 |
| 52.0 | Diver | 4 | line | 220 | 1 | 9.0 | |
| 55.0 | Mini-boss | 1 | line | 100 | 15 | 1.5 | |
| 58.0 | Scout | 6 | zigzag | 180 | 1 | 2.5 | |
| 61.0 | Scout | 9 | string | 170 | 1 | 2.5 | From right |
| 64.0 | Gunship | 3 | spread | 110 | 4 | 1.8 | |
| 68.0 | Kamikaze | 3 | swarm | 220 | 1 | 9.0 | From bottom |
| **72.0** | **Checkpoint** | | | | | | |

## Boss: Battleship

- **Name:** "Battleship"
- **Phases:** 1
  - Phase 1: 120 HP, attacks: spread + aimed, bullet speed 250, fire rate 1.8 s
- **Total HP:** 120
- **Part system:** none
- **Sprite:** DALL-E kraken/tentacle creature (`boss_processed.png`)

## Processing scripts (temporary)

These scripts were used to process DALL-E images and can be cleaned up:

- `scripts/boss_sprite_fix.gd` + `scenes/boss_sprite_fix.tscn` — boss sprite background removal processor (scale-first flood-fill approach)
- Run via: `Godot --headless --scene res://scenes/boss_sprite_fix.tscn`
