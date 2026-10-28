# Level 2 – Small City

## Theme

Urban rooftops with AA guns, helicopters, palm trees, and street lights. The second level increases enemy count, speed, and introduces multi-phase boss fights.

## Background

- **Background color:** olive green (0.35, 0.55, 0.25)
- **Far layer:** `textures/backgrounds/bg_02_far.png` — stitched DALL-E city rooftop tiles (720×3576 px). Three DALL-E images stitched into one tall non-repeating scroll.
- **Mid layer:** none (deleted — the detailed DALL-E far background makes mid-layer clash visually)
- **Near layer:** none (deleted — same reason as mid layer)
- **Decorations:** none (decoration system is ocean-themed, no city decorations exist)

### DALL-E source images

Stored in `sprites/level_02/`:
- `bg_city_1.png` — city rooftops with AA guns, palm trees
- `bg_city_2.png` — city rooftops continuation
- `bg_city_3.png` — city rooftops with street lights

### Background processing

The three DALL-E city tiles were stitched into one tall scrolling background using `scripts/bg_processor.gd`:
1. Each tile scaled to 720 px wide (maintaining aspect ratio)
2. Converted from RGB8 to RGBA8 format (required for `blit_rect` compatibility)
3. Stitched vertically using `Image.blit_rect()`
4. Output: `textures/backgrounds/bg_02_far.png` (720×3576 px)

Run via: `Godot --headless --scene res://scenes/bg_processor.tscn`

## Enemy palette

| Property | Color |
| --- | --- |
| Body | (0.35, 0.38, 0.22) — olive green |
| Accent | (0.45, 0.48, 0.28) — lighter olive |
| Detail | (0.85, 0.8, 0.2) — yellow |
| Name | "city" |

## DALL-E sprites

Level 2 uses DALL-E-generated enemy and boss sprites. Sprites are loaded at runtime via `GameManager.load_texture()` and rendered as Sprite2D children.

### Enemy sprites

| Enemy type | Sprite file | Notes |
| --- | --- | --- |
| Scout | `sprites/level_02/scout.png` | Also used for diver and kamikaze |
| Gunship | `sprites/level_02/gunship_processed.png` | Background-removed |
| Carrier | `sprites/level_02/heavy_processed.png` | Also used for mini_boss |
| Turret | (none) | Uses procedural drawing |

**Source DALL-E images** (pre-processing originals):
- `sprites/level_02/gunship.png`
- `sprites/level_02/heavy.png`
- `sprites/level_02/drone.png` (unused)

### Boss sprite

- **File:** `sprites/level_02/boss_processed.png`
- **Source:** `sprites/level_02/boss.png`

## Wave structure

Total wave duration: ~74 seconds before boss. Compared to level 1: more enemies per wave, higher speeds, and enemies have more HP in the second half.

| Time | Type | Count | Formation | Speed | HP | Shoot interval | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 10.0 | Scout | 5 | line | 160 | 1 | 3.0 | |
| 15.0 | Diver | 3 | v | 210 | 1 | 9.0 | |
| 20.0 | Turret | 3 | spread | 0 | 3 | 2.0 | |
| 26.0 | Scout | 6 | zigzag | 170 | 2 | 2.5 | |
| 29.0 | Scout | 8 | string | 180 | 1 | 2.5 | From right |
| 32.0 | Diver | 4 | line | 230 | 1 | 9.0 | |
| 35.0 | Diver | 3 | swarm | 240 | 1 | 9.0 | From bottom |
| 37.0 | Gunship | 2 | spread | 110 | 3 | 2.0 | |
| **42.0** | **Checkpoint** | | | | | | |
| 44.0 | Scout | 6 | v | 180 | 2 | 2.2 | |
| 50.0 | Turret | 4 | spread | 0 | 4 | 1.8 | |
| 55.0 | Diver | 5 | swarm | 240 | 2 | 9.0 | |
| 58.0 | Mini-boss | 1 | line | 100 | 18 | 1.4 | |
| 61.0 | Gunship | 3 | line | 120 | 4 | 1.8 | |
| 64.0 | Scout | 9 | string | 190 | 2 | 2.2 | From left |
| 67.0 | Scout | 8 | zigzag | 200 | 1 | 2.5 | |
| 70.0 | Kamikaze | 4 | swarm | 250 | 1 | 9.0 | From bottom |
| 70.0 | Scout | 8 | string | 180 | 1 | 2.5 | From right (simultaneous with kamikaze) |
| **74.0** | **Checkpoint** | | | | | | |

## Boss: Armoured Train

- **Name:** "Armoured Train"
- **Phases:** 2
  - Phase 1: 100 HP, attacks: spread + aimed, bullet speed 260, fire rate 1.6 s
  - Phase 2: 60 HP, attacks: circle + aimed, bullet speed 280, fire rate 1.4 s
- **Total HP:** 160
- **Part system:** none
- **Sprite:** DALL-E creature (`boss_processed.png`)

## Key differences from Level 1

- 10% more enemies per wave on average
- Enemy speeds 10–20% higher
- Some enemies have 2 HP in the second half (vs all 1 HP in level 1 first half)
- Mini-boss has 18 HP (vs 15)
- Boss has 2 phases (vs 1) with total 160 HP (vs 120)
- Simultaneous waves at t=70 (kamikaze + scouts from different sides)
- DALL-E enemy sprites for scout, gunship, carrier; boss sprite also added

## TODO

- [x] Generate DALL-E enemy sprites for level 2 enemy types
- [x] Generate DALL-E boss sprite for the Armoured Train
- [ ] Create city-themed background decorations (rooftop elements, water towers, etc.)
