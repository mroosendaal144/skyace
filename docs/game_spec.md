# Sky Ace – General Game Design Spec

Oct 14, 2026 · @Maarten · Updated Oct 28, 2026

## Overview

A portrait-mode vertical-scrolling shoot 'em up for Android, inspired by the arcade classic 1942. The player pilots an elite fighter through 10 levels, from Earth's oceans to deep space, destroying incoming enemy waves and defeating a boss at the end of each level.

- **Genre:** vertical scrolling shoot 'em up (shmup)
- **Core loop:** fly, shoot, dodge, collect upgrades, defeat the boss, advance
- **Scope v1:** 10 levels, 3 fighters (cosmetic choice at game start), 10 bosses
- **Session length:** 3 to 5 minutes per level, roughly 40 to 50 minutes for a full run

## Platform and tech

The game targets Android phones, built in Godot 4, locked to portrait orientation.

- **Engine:** Godot 4.7 with GDScript, 2D renderer
- **Orientation:** portrait only, reference resolution 720 × 1280, stretch mode canvas_items (keep_width). With keep_width, the viewport width stays at 720 but the height extends on phones with taller aspect ratios (e.g., ~1600 px on a 20:9 phone). All game bounds (player clamp, bullet despawn, decoration cleanup) and HUD positioning (health bar, bomb button, overlays) use the actual viewport height at runtime, not hardcoded 1280
- **Performance target:** stable 60 fps on mid-range devices (around 4 GB RAM)
- **Connectivity:** fully playable offline
- **Saves:** local save via ConfigFile (`user://save.cfg`) storing high score, unlocked level, difficulty, and selected fighter
- **Distribution:** Google Play Store
- **Texture filter:** nearest-neighbor (pixel art)
- **Input:** touch input with mouse emulation enabled for desktop testing
- **Version:** displayed on title screen bottom-left, set in `project.godot` under `application/config/version`
- **Runtime sprite loading:** textures are loaded via `GameManager.load_texture()` which uses `load()` (Godot's ResourceLoader) as primary method, falling back to `Image.load()` + `ImageTexture.create_from_image()`. This is critical for Android exports where `Image.load()` cannot read from the PCK archive. `GameManager.load_image()` provides a similar helper that returns an `Image`. All texture variables must use the `Texture2D` base type (not `ImageTexture`) since `load()` returns `CompressedTexture2D` in exported builds. Resource existence should be checked with `ResourceLoader.exists()` instead of `FileAccess.file_exists()`.
- **Android export:** debug APK built via Godot headless export with ETC2/ASTC texture compression. Debug keystore used for signing. Package: `com.skyace.game`

## Controls

The player steers with one finger; all main weapons fire automatically.

- **Movement:** absolute finger drag anywhere on screen. On touch-down the offset between finger and fighter is recorded; while dragging, the fighter position is set to `touch_position - offset`, giving 1:1 tracking without coordinate-scaling drift. Position clamped to x:[20,700], y:[40, viewport_height - 40].
- **Weapons:** auto-fire continuously every 0.12 seconds while the player is alive. Weapon type determines the firing pattern (see Weapons section).
- **Missiles:** auto-fire on a cooldown (varies by missile level), seeking the nearest enemy.
- **Special weapon:** a button in the bottom-right corner, labelled "BOMB" with remaining charge count. Also triggered by spacebar on keyboard.
- **Pause:** a small pause button ("II") at the top-right of the screen; the game also pauses automatically when the app loses focus. ESC key also toggles pause.

## Weapons and upgrades

There are three weapon types — **Beam**, **Straight**, and **Spread** — each with 5 upgrade levels. Missiles have 3 upgrade levels. Dying drops every weapon down by one level.

### Weapon types

| Type | Pickup color | Description |
| --- | --- | --- |
| Beam | Green | Continuous laser beam that damages enemies on contact |
| Straight | Red/Orange | Parallel bullet streams fired straight up |
| Spread | Yellow | Fan of bullets at increasing angles |

Picking up a weapon type you already have upgrades it (+1 level, max 5). Picking up a different weapon type switches to it at level 1. At max level, picking up the same type awards 500 bonus points instead.

### Spread levels (default weapon)

| Level | Pattern |
| --- | --- |
| 1 | Single bullet straight up |
| 2 | 3 bullets (center + ±0.15 rad) |
| 3 | 5 bullets (center, ±0.2 rad, ±0.35 rad) |
| 4 | 7 bullets (center, ±0.12 rad, ±0.25 rad, ±0.4 rad) |
| 5 | 9 bullets (center, ±0.1 rad, ±0.2 rad, ±0.35 rad, ±0.5 rad) |

### Straight levels

| Level | Pattern |
| --- | --- |
| 1 | 1 bullet stream |
| 2 | 2 parallel streams (10 px spacing) |
| 3 | 3 parallel streams |
| 4 | 4 parallel streams |
| 5 | 5 parallel streams |

### Beam weapon

A continuous laser that deals damage on contact every 0.10 seconds. Width increases per level (12, 22, 34, 48, 64 px). Maximum beam length: 1400 px (extends past top of 1280 px screen from any player position). The beam visually shortens to the nearest enemy hit and shows an impact glow at the contact point.

### Missiles

| Level | Count | Cooldown |
| --- | --- | --- |
| 1 | 1 homing missile | 1.5 s |
| 2 | 2 missiles | 1.2 s |
| 3 | 3 missiles | 0.9 s |

At max missile level, picking up a missile upgrade awards 500 bonus points instead.

**Missile behavior:** speed 500, turn rate 4.5, damage 3. Homes toward the nearest enemy in the "enemies" group, periodically re-acquires target. Spawns a small explosion on impact. Drawn as a blue rocket shape.

**Player bullet:** speed 900, damage 1 per hit, destroys on first contact. Drawn as a green laser with pulsing glow.

### Special weapon (Blastwave)

An expanding ring (max radius 900, speed 600) from the player's position that hits each enemy once for 50 damage and destroys all enemy bullets on screen (awarding 10 points each). The player starts each level with 2 charges, maximum 5. Triggers screen shake (15.0).

### Pickups

Dropped by destroyed enemies based on per-type drop chances:

| Pickup | Color | Symbol | Effect |
| --- | --- | --- | --- |
| Beam | Green glow | Vertical line | Switches to / upgrades beam weapon |
| Straight | Red/Orange | Dual lines | Switches to / upgrades straight weapon |
| Spread | Yellow | Triple fan | Switches to / upgrades spread weapon |
| Missile | Blue | Rocket shape | +1 missile level (max 3) |
| Shield | Cyan | Shield shape | Adds 30 shield points for 10 seconds |
| Health | Green | Cross (+) shape | Restores 25% of max health |
| Special | Yellow | Star shape | +1 special charge (max 5), only from carriers |

Pickups fall at speed 80, bob horizontally with a sine wave (amplitude 20), and despawn below viewport bottom + 60 px.

**Drop chances by enemy type:**

| Enemy type | Drop chance | Can drop Special |
| --- | --- | --- |
| Carrier | 100% | Yes |
| Mini-boss | 100% | No |
| Gunship | 30% | No |
| Turret | 25% | No |
| Scout | 10% | No |
| Diver | 8% | No |
| Kamikaze | 0% | — |

**Carrier pickup distribution:** Beam 15%, Straight 15%, Spread 15%, Missile 15%, Shield 15%, Health 15%, Special 10%
**Other enemy pickup distribution:** Beam 20%, Straight 20%, Spread 15%, Missile 15%, Health 15%, Shield 15%

**Carry-over:** weapon type and levels carry over between levels.

**Death penalty:** on losing a life, weapon level drops by 1 (minimum level 1), missile level drops by 1 (minimum level 1), chain multiplier resets.

## Fighters

The player chooses one of three fighters on the title screen before starting the game. The choice is cosmetic only; all fighters share the same stats and hitbox.

| Ship | Texture |
| --- | --- |
| Interceptor | `fighter_start_64.png` |
| Heavy | `fighter2_64.png` |
| Bomber | `fighter3_64.png` |

**Selection UI:** a panel overlay on the title screen showing three columns with texture preview and name button, plus a BACK button. Selected fighter is saved to disk.

**Shared stats (all fighters):**
- Max health: 100
- Max shield: 50 (starts at 0, gained via pickups)
- Collision hitbox: 20 × 20 px
- Movement: 1:1 drag ratio (no speed stat)
- Sprite scale: 1.875×

## Health, lives and difficulty

The player has 3 lives (on Normal), each with a health bar; shields absorb damage before health does.

- **Damage order:** shield first, then health. When health reaches zero, a life is lost.
- **Respawn:** the fighter respawns at position (360, viewport_height - 230) after a 1.5 second delay, with full health, shield reset to 0, and 2 seconds of invulnerability (blinking every 0.15 s).
- **Extra lives:** +1 life at 50,000 points and every 100,000 after that.
- **Contact damage:** enemies deal 20 damage on collision, bosses deal 30, boss parts deal 15.
- **Game over:** when all lives are lost, "GAME OVER" displays for 3 seconds, then a 5-second continue prompt. On continue: score resets to 0, lives reset to 3, weapons reset to level 1, special resets to 2 charges, and the current level restarts from the beginning.
- **Continues:** unlimited, but score resets to zero.

| Difficulty | Enemy bullet speed | Enemy health | Starting lives |
| --- | --- | --- | --- |
| Easy | 70% | 75% | 5 |
| Normal | 100% | 100% | 3 |
| Hard | 130% | 125% | 2 |

## Levels and bosses

The 10 levels move from Earth into space and back to strange worlds, each ending in a boss with escalating phases and attacks. See each level's individual spec file for detailed wave structure, boss mechanics, background layers, enemy palettes, and DALL-E sprite status.

| # | Level | Setting | Boss | Boss phases | Part system | Spec file |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Ocean | Open sea | Battleship | 1 | None | [level_01_spec.md](level_01_spec.md) |
| 2 | Small City | Rooftops | Armoured Train | 2 | — | [level_02_spec.md](level_02_spec.md) |
| 3 | Capital City | Skyscrapers | Flying Fortress | 2 | Wing (2) | [level_03_spec.md](level_03_spec.md) |
| 4 | Space Shipyard | Docking cranes | Shipyard Mech | 2 | Armor (2) | [level_04_spec.md](level_04_spec.md) |
| 5 | Asteroid Field | Drifting asteroids | Mining Dreadnought | 3 | Turret (3) | [level_05_spec.md](level_05_spec.md) |
| 6 | Lava Planet | Lava bursts | Magma Serpent | 3 | Segment (3) | [level_06_spec.md](level_06_spec.md) |
| 7 | Desert Wasteland | Sandstorms | Sand Colossus | 3 | Shield (2) | [level_07_spec.md](level_07_spec.md) |
| 8 | Space Armada | Capital ships | Fleet Commander | 3 | Armor+Turret | [level_08_spec.md](level_08_spec.md) |
| 9 | Deep Ocean Trench | Bioluminescent | Leviathan | 3 | Shield+Segment | [level_09_spec.md](level_09_spec.md) |
| 10 | Cyber Fortress | Neon grid | Cyber Overlord | 4 | All types | [level_10_spec.md](level_10_spec.md) |

**Boss attack patterns (5 types):**
- **Spread:** 5 bullets at angles [-0.4, -0.2, 0.0, 0.2, 0.4]
- **Aimed:** 3 bullets aimed at player with [-0.1, 0.0, 0.1] spread
- **Circle:** 12 bullets in a full circle at 0.8× speed
- **Barrage:** 5 bullets fired sequentially (0.1 s apart) downward with random spread
- **Sweep:** 8 bullets swept from -0.6 to +0.6 radians with 0.08 s delay between each

**Boss part systems:**
- **Wing:** when all parts destroyed, boss speed increases 1.4×
- **Armor:** while parts alive, boss takes only 40% damage; after all destroyed, takes 150% damage
- **Turret / Segment:** no special mechanic, just destructible sub-targets

Part destruction spawns an explosion, drops a random pickup, awards 200 points, and triggers screen shake (6.0).

**Boss behavior:** enters from top to y=120 at speed 100, then moves horizontally (speed 80) bouncing between x=140 and x=580. Phase transitions occur at HP thresholds. On defeat: 5 explosions at random offsets, screen shake (18.0), awards 1000 + (level × 500) points.

**Boss health bar:** visible at top of screen during boss fights, red on dark red background, 500 px wide, with boss name label.

**Warning banner:** "WARNING: BOSS_NAME" displays for 2.5 seconds before each boss.

**Level structure:** intro (10 s, no enemies) → wave section 1 → mid-level checkpoint marker → wave section 2 with a mini-boss → boss checkpoint marker → boss → "LEVEL CLEAR!" (2.0 s) → results overlay (3.5 s) → next level.

**Level banner:** displays level number and name for 3.0 seconds at the start of each level.

**Enemy speed scaling:** enemies gain an additional 5% speed per level on top of their base speed.

**After level 10:** "CONGRATULATIONS! YOU WIN!" displays for 5.0 seconds, then returns to the title screen.

## Enemies

A small set of base enemy behaviours is reskinned per level with unique color palettes, so each world looks different while the code stays reusable. Levels with DALL-E sprites use those instead of procedural drawing (see per-level specs).

| Type | Behaviour | Shooting | Health | Score | Drop chance |
| --- | --- | --- | --- | --- | --- |
| Scout | Flies in formation at set speed/direction, supports wave movement | Straight down, 300 speed | Low | 100 | 10% |
| Diver | Homes toward the player at full speed | Does not shoot | Low | 150 | 8% |
| Gunship | Moves to random hover height (100–350), then strafes horizontally at 0.4× speed | Aimed at player, 320 speed | Medium | 200 | 30% |
| Turret | Stationary (drifts with background scroll) | Aimed at player, 320 speed | Medium | 175 | 25% |
| Carrier | Moves down at 0.5× speed | 3-way spread, 280 speed | High | 300 | 100% |
| Kamikaze | Homes toward player at 1.3× speed | Does not shoot | Low | 125 | 0% |
| Mini-boss | Hovers and strafes (like gunship), hover range 120–250 | Randomly fires spread or aimed | Very high | 500 | 100% |

**Base enemy scale:** 1.15× (applied to all enemies via `scale` property).

**Formations (8 types):** line, v, zigzag, circle, column, spread, swarm, string

**Spawn sides:** top (default), left, right, bottom

**Enemy visuals:** enemies are drawn procedurally via `_draw()` with per-level color palettes by default. Each level (1–10) has a themed palette (ocean, city, capital, industrial, rock, lava, desert, fleet, aqua, cyber) with body, accent, and detail colors. Levels with DALL-E sprites override procedural drawing — the `_draw()` method returns early when a sprite is loaded.

**Sprite system:** `SPRITE_MAP` in `enemy.gd` maps `{level_number: {enemy_type: sprite_path}}`. When a match exists, the enemy loads the sprite at runtime, creates a Sprite2D child node at 1.3× scale, and skips procedural drawing. Turrets always use procedural drawing. Levels without entries in SPRITE_MAP fall back entirely to procedural drawing.

Enemy waves are defined in JSON data files (`data/levels/level_XX.json`) listing spawn time, enemy type, count, formation, speed, HP, shoot interval, and spawn side.

## Boss sprite system

Bosses can use DALL-E sprites instead of procedural drawing. `BOSS_SPRITES` in `boss.gd` maps `{level_number: sprite_path}`. When a sprite is loaded:
- A Sprite2D child is added to the boss node
- All Polygon2D children (Hull, Core, Eye, LeftCannon, RightCannon) are hidden
- The collision shape is resized to match the sprite (e.g., 160×100 for level 1)
- The boss z_index is set to 10 (above background decorations at z_index 1)

Levels without entries in BOSS_SPRITES fall back to procedural Polygon2D drawing.

## Background system

Backgrounds use a multi-layer parallax system with runtime-loaded textures.

### Layer architecture

| Layer | Script | z_index | Speed | Content |
| --- | --- | --- | --- | --- |
| Background color | starfield.gd | default | — | Solid color per level theme |
| Decorations | bg_decorations.gd | 1 | 30 px/s | Random scrolling decorations (level-specific) |
| Far | starfield.gd | default | 20 px/s base | `bg_XX_far.png` — main terrain/environment |
| Mid | starfield.gd | default | 40 px/s base | `bg_XX_mid.png` — mid-ground elements (optional) |
| Near/Foreground | foreground.gd | 100 | 60 px/s | `bg_XX_near.png` — foreground particles/effects (optional, renders above player) |
| Enemies/Bosses | — | 10 | — | All enemies and bosses render above decorations |

### Texture loading

- Textures are loaded from `textures/backgrounds/` using the pattern `bg_XX_far.png`, `bg_XX_mid.png`, `bg_XX_near.png`
- Loaded via `GameManager.load_texture()` (ResourceLoader primary, `Image.load()` fallback)
- Existence checked with `ResourceLoader.exists()` (not `FileAccess.file_exists()`)
- Images are auto-scaled to 720 px width if needed
- Textures tile vertically while scrolling (seamless wrap)
- Drawing copies calculated from actual viewport height (not hardcoded 1280)
- Background scroll speed ramps up based on spawner progress (1.0× to 5.0× via `_speed_mult`)
- Missing texture files are handled gracefully (layer doesn't render)

### Decoration system

- `bg_decorations.gd` loads textures from `textures/decorations/` (islands, edge cliffs, ships)
- Decorations spawn at random intervals (2.0–4.5 s) and scroll down at 30 px/s, despawning below viewport bottom + 300 px margin
- Minimum spacing of 400 px between island decorations
- Textures are feathered at edges (30 px margin) for blending
- Currently only ocean-themed decorations exist (level 1)
- Note: `_load_textures()` is not called in `_ready()`, so decorations do not currently spawn

### Per-level background colors

Background colors, layer details, and DALL-E source image inventories are documented in each level's individual spec file (see links in the Levels and bosses table above). The colors are defined in `starfield.gd:_bg_color()`.

### Shared far backgrounds

Some levels reuse another level's far background texture via the `SHARED_FAR` map in `starfield.gd`:
- Level 5 (Asteroid Field) uses level 4's far background
- Level 8 (Space Fleet) uses level 4's far background

## Z-index layering

| z_index | Content |
| --- | --- |
| default (0) | Background layers (far, mid) |
| 1 | Background decorations (islands, ships) |
| 10 | Enemies and bosses |
| 50 | Player explosion |
| 100 | Foreground/near parallax layer |

## Collision layers

| Layer | Purpose |
| --- | --- |
| 1 | Player |
| 2 | Player projectiles (bullets + missiles + beam) |
| 4 | Enemies (enemies, bosses, boss parts) |
| 8 | Enemy bullets |
| 16 | Pickups |

## Scoring, UI and screens

Score rewards aggression: a chain multiplier rises as the player keeps destroying enemies without getting hit.

- **Points:** per enemy destroyed (100–500 depending on type), boss bonus (1000 + level × 500), bullet-clear bonus (10 per bullet destroyed by blastwave).
- **Multiplier:** rises from ×1 to ×8 at discrete thresholds (8 kills = ×2, 16 kills = ×4, 32 kills = ×8); resets when the player takes damage or loses a life.
- **In-game HUD:** score and multiplier (top-left, multiplier in yellow, hidden at ×1), lives (top-right), level name (top-center), pause button (top-right corner), health bar (bottom-left, green), shield bar (above health, cyan), shield countdown timer display, special weapon button with charges (bottom-right, yellow), boss health bar with name (top, during boss fights), center-screen message for banners.

**Pause overlay:** full-screen dark overlay with "PAUSED" text, Resume button, and Quit to Menu button. All buttons styled with blue-tinted StyleBoxFlat. HUD runs in PROCESS_MODE_ALWAYS.

**Screens implemented:**

1. **Title screen:** "SKY ACE" title (cyan, size 72) + "VERTICAL SHOOT 'EM UP" subtitle, with PLAY, CONTINUE (hidden if no progress), SETTINGS, LEVEL SELECT, and EXIT buttons. High score display. Version label anchored at bottom-left. Test mode toggle button at top-right.
2. **Fighter select panel:** vertically centered overlay on title screen with 3 fighters shown side by side (Interceptor, Heavy, Bomber). Uses anchor_top/bottom = 0.5 for centering on all aspect ratios.
3. **Level select panel:** vertically centered overlay allowing replay of any level 1–10. Shown when LEVEL SELECT is pressed.
4. **Settings panel:** vertically centered overlay on title screen with Easy / Normal / Hard difficulty buttons.
5. **In-game HUD and pause menu.** Health bar and bomb button anchored to screen bottom (anchor_top/bottom = 1.0). Pause and results overlays fill actual viewport via anchors.
6. **Level results overlay:** shows level number, score, enemies destroyed, and total score.
7. **Game over and continue screen.**
8. **Win screen:** "CONGRATULATIONS! YOU WIN!" after level 10, returns to title.

## Art and visuals

Mixed pixel art and DALL-E generated sprites.

- **Player sprites:** 64 × 64 px textures for each fighter variant, loaded at runtime via `GameManager.load_texture()`.
- **Enemies:** procedurally drawn by default with per-level color palettes. Levels with DALL-E sprites override this (see per-level specs).
- **Bosses:** procedurally drawn via Polygon2D nodes by default. Levels with DALL-E sprites hide the Polygon2Ds and show the sprite instead.
- **Pickups:** procedurally drawn with unique shapes per type (beam line, dual lines, triple fan, rocket, shield, cross, star) and pulsing glow outline.
- **Bullets:** player bullets are green lasers with glow; enemy bullets are small red/orange circles; missiles are blue rocket shapes.
- **Backgrounds:** per-level with up to 3 parallax layers. Some levels use procedurally generated textures, others use DALL-E generated and processed images.
- **Explosions:** 14 procedural particles expanding and fading over 0.45 s, with initial flash and smoke ring. Player death uses a separate, larger explosion effect (z_index 50).
- **Screen shake:** triggered at varying intensities (6.0–20.0) for boss part destruction, player death, boss defeat, level clear, and blastwave. Decays at 0.88× per frame.
- **Hit flash:** enemies and bosses flash white for 0.05 s when hit.
- **Player damage glow:** when the player takes health damage (not absorbed by shield), a red glow flares around the ship for 0.2 seconds and fades out. Separate from the shield hit flash — both can play independently.
- **Shield bubble:** while the shield is active, a translucent blue bubble (radius 38) surrounds the fighter with a gentle breathing pulse. On shield hit: flashes red for 0.15 s. On shield break: flashes red, expands outward and fades over 0.3 s.
- **Banking visual:** bank angle is tracked based on horizontal movement but currently disabled (rotation, scale.x, and skew are reset to defaults every frame). Planned: player sprite rotates up to 15° with a scale-x squeeze for pseudo-3D banking.

## Monetization and extras

A one-time purchase or a free demo of levels 1–3 with a single unlock for the full game, with no ads during gameplay.

## Not yet implemented

The following features from the original design are planned but not yet built:

- [ ] **Audio system:** music tracks, boss theme, sound effects (lasers, missiles, explosions, pickups, warnings, menu clicks), volume settings
- [ ] **Fighter stat system:** per-fighter speed, health, shield, firepower, and missile stats (currently all cosmetic)
- [ ] **Fighter special traits:** smaller hitbox (Swift), shield regeneration (Bulwark), dash on double-tap (Phantom), extra special charge (Titan), dual missile pods (Annihilator)
- [ ] **Mid-game fighter choice:** selection screens after levels 3 and 7 with stat bars and laser pattern previews
- [ ] **7-fighter roster:** expand from 3 cosmetic ships to the full 7 (Falcon, Swift, Bulwark, Striker, Phantom, Titan, Annihilator)
- [ ] **Piercing core beam:** laser level 5 should add a piercing center beam that passes through enemies
- [ ] **Missile blast radius:** missile level 3 should have area-of-effect damage
- [ ] **Touch offset:** finger drag should offset the ship above the touch point so the finger never covers it
- [ ] **Checkpoint system:** checkpoint markers exist in level data but the restore mechanic is not functional; game over restarts the entire level
- [ ] **Formation bonus:** destroying all scouts in a formation should award a bonus pickup
- [ ] **No-damage boss bonus:** bonus score for defeating a boss without taking damage
- [ ] **Accuracy tracking:** track and display shot accuracy in level results
- [ ] **Time tracking:** track and display completion time in level results
- [x] **Level select screen:** implemented, allows playing any level 1–10 (no unlock gating in test mode)
- [ ] **High scores screen:** per-level and full-run high score display
- [ ] **Credits / ending screen:** proper credits after completing level 10
- [ ] **Settings:** music volume, sound volume, vibration toggle, control sensitivity
- [ ] **Vibration / haptic feedback:** short vibration on damage
- [ ] **Level-specific environmental hazards:** sandstorms reducing visibility, currents pushing the ship, splitting asteroids, etc.
- [ ] **Google Play Games:** leaderboards, achievements, cloud saves
- [ ] **Analytics:** anonymous level-completion and death-location data
- [ ] **Background decoration system:** `_load_textures()` in `bg_decorations.gd` is never called from `_ready()`, so decoration spawning is currently inactive

## Open questions

- [ ] Story: is there a narrative (briefings, a pilot character, an enemy faction) or pure arcade action?
- [ ] Endless or arcade mode after level 10?
- [ ] Business model: paid, or free demo with full-game unlock?
