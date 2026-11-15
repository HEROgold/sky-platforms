# Gameplay flow

Approved 2026-11-15, after the planet-timer and start-mode prototypes and a grilling session. Each section names the issue that holds the decision. Numbers marked "spec" are not set yet; they get set in the specs.

## 1. Start

- The player starts in a new space location called **the Drift**. It has all three asteroid types: metallic, carbonic and oxide.
- The player has one platform and no lander.
- The player is a normal character standing on the platform, with handcrafting on (#6).
- Empty space blocks movement, as in vanilla. The starting kit includes **mech armor**, which lets the player fly over empty space between platforms and over obstacles on planets (#6).
- Losing the armor over empty space kills the character, as in vanilla. Each player picks a respawn point, the home platform by default. The dead character's items move to the home platform hub (#6).
- Starting kit, double the lean kit: 4 asteroid collectors, 4 crushers, 4 assemblers, 4 furnaces, 2 labs, solar panels, inserters, belts, foundation, mech armor, and one Thud damper.
- Thud's damper tech (`thud-orbital-ascent`) starts researched.

## 2. Orbit phase

- New asteroid recipes give copper and stone at low yields from the start. Vanilla asteroids only give iron, carbon and ice until advanced crushing, which is late game.
- Thruster research costs red science only, so the first trip comes after about 15 minutes of bootstrapping. A rescued player can always rebuild thrusters this way.
- The orbit alone can make red and green science slowly. Bulk ore, oil, coal, uranium and planet specials come only from planets.

## 3. Planets

- The vanilla planets are hidden. Fleeting planets come in types based on them: Nauvis-like, Vulcanus-like, Fulgora-like, Gleba-like and Aquilo-like.
- Planets live in a fixed pool of slots defined at data stage, because mods can't add planets at runtime. Each visit regenerates a slot with a new seed and resource profile (#3).
- Every slot connects to the Drift and to the other slots, so platforms can hop between planets.
- Types unlock by planets visited: only Nauvis-like at first, then Vulcanus-, Fulgora- and Gleba-like after 4 visits, then Aquilo-like after 12 (#9).
- The player sees the next two planets, with type and resources, before they arrive (#9).
- A pity rule, default 6 and set by a map setting, guarantees a type or uranium that hasn't appeared in the last N planets (#9).
- Uranium appears on half of the Nauvis-like planets. Every other type always carries its special (#9).
- A new planet waits in its slot until someone lands or the player skips it. Skipping costs items at a scanner building, which circuits can trigger (#7).

## 4. Landing and the timer

- Any platform can land where Thud allows it, including the main base (#5).
- The first landing starts the countdown. The default is **30 minutes**, set by a map setting, with staged warnings from the first second (#7).
- At half-life the next planet appears, if a slot is free. At most two planets are live at once (#7).
- Drills on the landed platform mine the ore underneath. Drills built on the ground around it mine faster, but they stay behind at take-off and are lost when the planet collapses.
- A folded rocket silo twin can ride on a platform, so the silo doesn't stay behind.
- Near zero, the mod starts take-off for every landed platform whose damper charge is full. A platform without enough charge is lost with the planet. That is the penalty for bad power planning (#7).
- Any number of platforms can orbit or land on the same planet (#7).

## 5. Timer research

1. Stage 1: three techs take every planet from 30 to 45 minutes.
2. Stage 2: techs for each planet type, which lengthen that type's timer only. The Nauvis-type tech needs uranium and nuclear science from `atan-nuclear-science-fork`.
3. Stage 3: one tech for every planet, using all planet sciences.

The maximum is 2 hours.

## 6. More platforms

- Normal mode: launch starter packs from a rocket silo on a landed planet.
- Easy mode: an orbital building that creates platforms by script.

## 7. Planet sciences

- Made on the matching planet type, as in vanilla. Vulcanus science needs lava, Gleba science needs fresh fruit, and Aquilo science needs its ocean.
- Easy mode adds orbital recipes for them.

## 8. Enemies

- Vanilla enemies for each planet type, with a map setting to turn them off.
- Evolution is tracked per surface, so every fresh planet starts at zero. Scaling the starting evolution with game progress is to be tested later.

## 9. Losing a platform

- A snapshot of the home platform is taken every 30 minutes. The home platform is the starting one unless the player picks another.
- The snapshot holds only the layout: buildings and tiles, with hubs empty. Vanilla doesn't allow chests on platforms, so nothing can be duplicated this way.
- A rescue restores the snapshot with 20% of buildings and tiles removed at random, at home orbit by default (a setting). Research is kept.
- Without a snapshot, the player gets a new starting kit platform.

## 10. Winning

- **Story ending:** research the planetary anchor using all planet sciences, pay a quota of every planet special, and build the anchor on a landed planet. That planet becomes permanent.
- **Vanilla ending:** reach the solar system edge.

## 11. Modes and settings

- **Easy mode:** platforms always take off and lose nothing, platforms can be built in orbit, and planet sciences have orbital recipes.
- **Multiplayer:** at release the default is separate forces racing for the same planets, with co-op on one force as a setting. Co-op gets built first.

## 12. Dependencies

- Thud (required).
- `atan-nuclear-science-fork` (required), unless the original Nuclear Science gets a 2.1 release, which we would then support instead.

## Not in scope for now

- Race mode itself.
- Timer techs for modded planets.
- The progress-scaled enemy evolution test.
