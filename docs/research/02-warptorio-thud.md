# Research: Thud and Warptorio

Research date: 2026-11-15. All facts below were read from the cited pages on that date. Where a source did not load or did not say, this file says so.

## Factorio version check

- Factorio 2.1 reached stable on 2026-10-23, per GamingOnLinux ("Factorio 2.1 is out now"): https://www.gamingonlinux.com/2026/10/factorio-2-1-is-out-now-with-the-native-arm64-linux-build-to-run-on-steam-frame-raspberry-pi-and-more/
- A search summary gave 2.1.23 as the current build. I did not confirm that number on a primary page (Wube's site was not fetched).
- Consequence: Thud 2.x targets 2.1 only. Our mod must target Factorio 2.1.21 or later if it depends on Thud.

## 1. Thud (T.H.U.D, Total Hull Unscheduled Descent)

### Hard facts

| Item | Value | Source |
|---|---|---|
| Owner | Klaudia | https://mods.factorio.com/api/mods/Thud/full |
| Downloads | 462 | same |
| Created | 2026-10-11 | same |
| Releases | 2.1.0 (10-11), 2.1.1 (10-17), 2.1.2 and 2.1.3 (10-18), 2.2.0 (11-15, today) | same |
| Factorio | 2.1 only. Needs base and space-age >= 2.1.21 | same |
| License | MIT | same |
| Source repo | None. The homepage field is empty and a web search found no GitHub repo | https://mods.factorio.com/api/mods/Thud/full , search results |
| Dependency on other mods | Space Age required | https://mods.factorio.com/mod/Thud |

Reuse: MIT allows depending on it and copying code. The lack of a public repo means we cannot read the Lua source. A mod download needs a portal login, and I did not attempt it.

Maintenance status: active. Five releases in five weeks, and the author replies to threads (https://mods.factorio.com/mod/Thud/discussion). The mod is new and has a small user base, so expect API churn. Version 2.2.0 added the `thud` remote interface the same day this was written, so it has no track record.

### What it does

Thud lets a whole space platform land on the planet it orbits. It does not teleport single entities.

- A button on each platform hub starts an "emergency landing". You aim with a preview, then the platform descends. Tiles, machines, cargo, wires, fluids and anyone aboard land together. (https://mods.factorio.com/mod/Thud/changelog, 2.1.0 entry)
- An alarm and a growing shadow warn people at the site. Anything at the landing site is destroyed, with a warning if it belongs to the player. (same)
- After landing, the hub becomes a "Landed platform hub", which works as a cargo landing pad. The landed floor forms one electric network that one pole can connect to the grid. (same)
- 2.2.0 adds the superconducting inertial damper. With dampers a platform lands softly and can take off again. Soft landings never land on your buildings or over water. (https://mods.factorio.com/mod/Thud/changelog)
- 2.2.0 also adds a 20 second plunge for emergency landings, a "Jump efficiency" research (three levels, charge cost down 20%, 35%, 50%), circuit control of dampers, and a starter pack that starts a platform already on the ground. (same)
- Players can leave the hub and walk on the deck (2.2.0). (same)
- Anything can be built anywhere in 2.2.0. Machines that cannot work on the current surface stand idle and say why. On an emergency landing, such machines come down wrecked. (https://mods.factorio.com/mod/Thud , changelog)
- On take-off, whatever cannot go up stays behind after a warning. (https://mods.factorio.com/mod/Thud)

Fit with our concept: Thud moves the platform to the planet, not the player. The "player lands on a planet, platform stays in orbit" idea is not what Thud does. Our "no character body" start and the "temporary planet" loop have to be reconciled with Thud's model, in which the factory itself lands. One option is a small dedicated lander platform that uses soft landing and take-off, with the main factory platform staying in orbit. That is a design inference, not something Thud documents.

### Limits

- Landing needs solid ground. Water and lava refuse a landing unless the player shift-clicks, which leaves the part over the liquid behind. (https://mods.factorio.com/mod/Thud)
- Hub, landing pads, rocket silo, lightning attractors and spidertrons cannot be built where they do not belong. (https://mods.factorio.com/mod/Thud)
- A platform that loses its hub on the way comes down as burning wreckage. (same)
- Platform size limit, entity-type limit and performance numbers: the page states none. The only performance statement is the 2.1.1 changelog line about better landing-preview, sprite and landing performance. (https://mods.factorio.com/mod/Thud/changelog) I could not find a UPS figure for large platforms.
- Thud has no check for modded planet rules. The author says "it has no code checking for modded planets", so it can bypass limits such as another mod's cargo-drop tech requirement. (https://mods.factorio.com/mod/Thud/discussion/6ace021c339a4ef7a517b45d). We would need to enforce our own rules.
- It can be added to an existing save because it only adds a button to the hub GUI. (same thread)

### Known bugs and open requests (discussion page, 9 threads)

Thread list: https://mods.factorio.com/mod/Thud/discussion . Reply text of some threads did not load, so those are marked by title only.

- Load crash, "extra-high-alt is unknown sprite priority", caused by the mod Nexus. A second crash came from the planet mod Carna (sprite size error). Fixed in 2.1.2 and 2.1.3. https://mods.factorio.com/mod/Thud/discussion/6ad4ad7fdce0d35cd538faab
- Open request to disable trains and chests on the ship and to adjust the ascent cost (title only, 0 replies). https://mods.factorio.com/mod/Thud/discussion
- "Platform Emergency Landing does not work" (bug, title only, 2 replies). Same page.
- Roboports on platforms: a third-party mod, thud-dormant-roboports, swaps "dormant" duplicate prototypes by surface type. The author said she will support the use case more directly. https://mods.factorio.com/mod/Thud/discussion/6aceec1a7062a4f3cc4f4002 . The Landed hub also works as a cargo landing pad because deliveries could not be blocked, and she kept that as a feature. (same thread)
- Blueprint tint on the cursor for aiming: implemented in 2.1.1. https://mods.factorio.com/mod/Thud/discussion/6ad13cfc99bde6d0fa840f9d

### Integration notes

What the portal text shows (exact names, quoted from the description via https://mods.factorio.com/api/mods/Thud/full):

- Remote interface name: `thud`. The description says "Scenarios and other mods can do what the buttons do through the `thud` remote interface". It covers emergency or soft landing, setting a landing site, take-off, reading and setting the dampers' charge and circuit conditions, and reading whether a platform is landing or taking off. "Each is refused for the same reasons as the button, saying why."
- I could not read function names or parameters. The description lists no `remote.call` signatures, and there is no source repo. Before building, someone must either read the `thud` interface from the downloaded mod (`remote.interfaces["thud"]` in game, or open the zip after logging in to the portal) or ask Klaudia on the discussion page.
- Prototype-stage mod-data tables (names from the description and changelog, shapes only partly shown):
  - `data.raw["mod-data"]["thud-landing-replacements"]`, mapping a platform-only entity to its ground version, for example `"my-platform-twin"` to `"my-machine"`. Both entities must be minable, share a `fast_replaceable_group` and have the same collision box. Contents, settings, wires, quality and health carry over. (https://mods.factorio.com/mod/Thud/discussion/6aceec1a7062a4f3cc4f4002 , https://mods.factorio.com/mod/Thud)
  - `"thud-twins"` with `folded` and `dormant` pairs. (https://mods.factorio.com/mod/Thud)
  - `"thud-descent-seconds"` sets a planet's descent time. (same)
  - `"thud-surface-conditions"` holds surface conditions (moved there in 2.2.0). (https://mods.factorio.com/mod/Thud/changelog)
- Dependency form: add `"? Thud"` for optional use. For a hard dependency use `"Thud >= 2.2.0"`. Note the portal name is `Thud` with a capital T.
- Events: no events are documented. I found no mention of custom events, so assume we must poll the remote interface's landing and take-off state, or watch the platform's surface ourselves. Ask the author whether events exist.

What we would have to build ourselves:

- The planet picker, planet generation and the "temporary, fleeting planet" lifecycle. Thud lands on the planet the platform orbits, so we must create or select that planet. I found no evidence Thud accepts custom or generated surfaces. Its author says it does not check modded planets, which suggests it works on any planet surface, but that is unconfirmed.
- The timer and forced take-off or forced evacuation. Thud has no timer. Take-off needs damper charge, and Jump efficiency research reduces that charge. A timer must respect damper charge, or we must force a take-off through the remote interface and handle refusals ("refused ... saying why").
- Rules for what survives. Thud leaves behind what cannot go up, so a forced take-off may strand entities.
- Resource-return logic, for example moving collected uranium from the landed hub to the orbiting factory.
- Starting without a character. Thud's 2.2.0 deck walking and our no-body concept need testing together.
- Control of the abuse cases in the open requests (trains and chests aboard, ascent cost).

Risks: new mod, one author, no public source, 2.1 only, API first shipped today. Pin the version and keep a thin adapter layer in our mod so a Thud API change touches one file.

## 2. Warptorio and its lineage

### Hard facts

| Mod | Owner | Downloads | License | Source | Status | Source of facts |
|---|---|---|---|---|---|---|
| Warptorio (original) | NONOCE | 124 | MIT | none given | Last release 0.2.1, 2019-05-26, Factorio 0.17, alpha | https://mods.factorio.com/api/mods/warptorio/full |
| Warptorio2 | PyroFire | 34,617 | PyroFire's Factorio Mod License (custom) | github pyrofire232/warptorio2, Patreon | Last release 1.3.10, 2023-05-08, Factorio 1.1.80 | https://mods.factorio.com/api/mods/warptorio2/full |
| Warptorio 2.0 (Space Age) | Venca123 | 14,423 | GNU GPLv3 on the portal. The repo says GPL-2.0, so the two disagree | https://github.com/VencaCZ/warptorio-space-age | Active. 0.4.7 on 2026-10-27, Factorio 2.1, 3 stars, 12 forks, 5 open issues | https://mods.factorio.com/api/mods/warptorio-space-age/full , https://github.com/VencaCZ/warptorio-space-age |
| Warptorio 3 (No Space Age) | IamfindingNemo | 1.69K | MIT | none listed | v2.6.4, Factorio 2.0 to 2.1, requires Space Age disabled | https://mods.factorio.com/mod/warptorio3_2 |

Reuse: Warptorio SA is GPL, so copying its code into our mod forces our mod to be GPL as well. Using its remote interface or events as an optional dependency is a separate matter, and I am not giving a legal opinion. Warptorio2's custom license needs reading before any reuse; I did not read it. Warptorio 3 (No Space Age) is MIT but cannot run alongside Space Age, which Thud requires.

Warptorio SA also has an upload dated 2025-02-18 and a 2.0 line that moved to 2.1 at 0.4.0 (2026-06-29), with `+quality` required. (https://mods.factorio.com/api/mods/warptorio-space-age/full)

### Why earlier versions died

- Original Warptorio: alpha, one author, last release 2019-05-26 for Factorio 0.17, with known game-breaking bugs and untested multiplayer. (https://mods.factorio.com/api/mods/warptorio/full) The Space Age author lists Nonoce as the origin and PyroFire as the Warptorio2 author. (same API page for SA)
- Warptorio2: page shows compatibility 0.17 to 1.1 and no 2.0 build. Threads asking for 2.0 support ("Will 2.0 compat be a thing?", "Please update Warptorio?") went unanswered by the author for about two years. The last PyroFire replies were 2 years old. https://mods.factorio.com/mod/warptorio2/discussion . I found no statement from PyroFire that the mod was dropped, so the real reason is unconfirmed. The cause looks like loss of maintainer time, plus the 2.0 rewrite and Space Age. Treat that as inference.
- The 2.0 port was done by others: Shadow_Man and Nemo for the No Space Age bundle (https://mods.factorio.com/mod/warptorio3_2), and Venca123 for Space Age, who says no one else had made it work in 2.0 (https://mods.factorio.com/api/mods/warptorio-space-age/full).
- A competing 2.0 mod, Dimension Warp, and Warp Drive Machine exist. The Warptorio SA author recommended both to a player who wanted a style closer to the original. https://mods.factorio.com/mod/warptorio-space-age/discussion/67e6efa0f0c04f57bcb70a71

### Mechanics

Warptorio2 (1.1):

- Warp button top left. Each warp takes less time to set up than the last, but charge time grows with the number of warps. Planets have traits (rich in one resource, missing others). Loot chests spawn on planets, which rewards some exploration before leaving. The warp reactor unlocks upgrades. https://mods.factorio.com/api/mods/warptorio2/full
- The manual warp timer rises after each warp. The auto-warp timer does not. Source: PyroFire's reply at https://mods.factorio.com/mod/warptorio2/discussion/5ee90394d9921f000b7c40c6
- Biters grow more aggressive with each warp. The player balances gathering against leaving before defenses fail. (summary on the Warptorio2 API page)

Warptorio 2.0 Space Age (SA):

- The warp engine and timer do not start until green science or the Warp Platform is researched. (https://mods.factorio.com/api/mods/warptorio-space-age/full) A thread confirms the countdown starts on green science and the game gives no message about it. https://mods.factorio.com/mod/warptorio-space-age/discussion/67c083d41a041f506a7b5fd6
- Auto-warp timer: a player reports "a ten minute auto-warp timer" in the early game. https://mods.factorio.com/mod/warptorio-space-age/discussion/67cf9cf2db3541d6f0fb1885 . Research extends the maximum time, and a Gleba requirement gates it. (thread 67c083d..., author reply). The number of 10 minutes is one player's report, not an official figure. The changelog for 0.4.0 says a shorter first-planet timer is now the default. (https://mods.factorio.com/api/mods/warptorio-space-age/full)
- A player at warp 13 to 15 minutes reports bosses appear and extra time "mostly means constant defense and higher ammo use". https://mods.factorio.com/mod/warptorio-space-age/discussion/6a6e97aa32ff991e0ced2534
- Manual warp opens once the central accumulator charges. (thread 6a78b7dffef228be32ff6120 says the accumulator shows charge level; the alert requests refer to when manual warp becomes available)
- Players vote on warps in multiplayer (0.2.5). Admins can force a warp with shift-double-click (0.4.4). (changelog, API page)
- In 0.4.4 a chat warning appears 60 seconds before the Nauvis time limit and an on-screen countdown appears before forced warps. (changelog)
- The next planet is chosen by the mod, shown in a rolling display, and the "same planet twice in a row" case is limited. 0.0.4 prevents the same void planet twice in a row. 0.2.9 made repeated two-planet hopping harder. 0.2.10 added a new next-planet selection method. (changelog) A manual next-planet pick was requested at https://mods.factorio.com/mod/warptorio-space-age/discussion (thread "Manually select the next planet to warp", no reply content read).
- What carries over: the platform, the player base on the factory floors and the ground platform, and warp chests, trains (warp trains, 0.2.13) and asteroid collectors. Planet-specific recipes reset after warping, announced to "encourage temporary bases" (developer reply at https://mods.factorio.com/mod/warptorio-space-age/discussion/68b9ebed695f0a2b428f48e7). Platforms from past warps can respawn ("raiding past platforms", per 512nm's feedback and the 0.4.3 option to remove them).
- Planet generation: planet variants are added through the remote interface function `edit_planet_variants`, using map-gen settings exported to JSON and converted to Lua. All planets and their research are supported, and new planets can be added "the same way as in Space Exploration". https://mods.factorio.com/api/mods/warptorio-space-age/full (description, "Interfaces since 0.2.8")
- Enemies: waves are time-based and pollution-based, so the author can schedule bosses and extra attacks. https://mods.factorio.com/mod/warptorio-space-age/discussion/67c083d41a041f506a7b5fd6

### What players loved

- The garden floor. "hands down the best and most interesting part" (search summary of portal threads) and "praised the garden floor as the best feature". https://mods.factorio.com/mod/warptorio-space-age/discussion/69a22f9f7e42920ceb958070
- The early game is stressful but fun. A 144 hour player on easy says so, and says robots made the mid game smoother. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a143bbf51bed9392d282917
- Combining tech across planets and platforms. https://mods.factorio.com/mod/warptorio-space-age/discussion/699b9b4dd380e7a3c7b47652 (512nm)
- The planet-hopping early game and productivity buildings. https://mods.factorio.com/mod/warptorio-space-age/discussion/67e6efa0f0c04f57bcb70a71
- Several full completions on YouTube, listed by the author as a "hall of fame": Rasukoniko, Pettan, JohnMegacycle, Eggsceptional. https://mods.factorio.com/api/mods/warptorio-space-age/full . I did not open the videos, so I have no view counts.
- Reddit: I found no r/factorio threads through search. Search results returned portal threads and a Reddit mirror weekly-question thread I did not read. This leaves a gap for reddit praise and complaints.

### What players found frustrating

- Silent timer start. The wave timer starts when green science finishes, with no warning. Five minutes later two waves arrived together (about 50 biters) and wiped out a stockpile. Ground platform spawn location and the 10 minute auto-warp also started with no notice. https://mods.factorio.com/mod/warptorio-space-age/discussion/67cf9cf2db3541d6f0fb1885
- No klaxon. "EVERY time, the warp out catches me by surprise." https://mods.factorio.com/mod/warptorio-space-age/discussion/6a82c1675dabdceb7003da1f was in search results but I opened https://mods.factorio.com/mod/warptorio-space-age/discussion/69938035d7b0a28a6ecf11b8 instead, the thread "I miss the Klaxon" by Zaanzabar. The author promised more custom alerts in 0.3, and 0.4.4 added the 60 second warning.
- Timer too short early, enemies too strong, platform too small. "The warp timer is too short." https://mods.factorio.com/mod/warptorio-space-age/discussion/69a22f9f7e42920ceb958070 (Flamebeard10339, in the thread I opened)
- Longer timers make play tedious. A longer timer means constant defense and ammo use, and one player will not endure it on every planet for 10 extra minutes. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a6e97aa32ff991e0ced2534
- Revisiting a planet after building defenses often loses the base, because waves do not reset. Same thread.
- Losing builds: turrets lost whenever demolishers came; floor upgrades destroyed corner buildings; hotbar spidertron groups erase on warp (thread title, no content read). https://mods.factorio.com/mod/warptorio-space-age/discussion
- Waves and evolution ramp fast. Hard to stay past about 15 minutes once evolution passes 50%. https://mods.factorio.com/mod/warptorio-space-age/discussion/67e6efa0f0c04f57bcb70a71 (the thread titled with Wolverineslayer8's feedback)
- Logistics between platforms is weak, and liquid mining (lithium on Aquilo) is a headache, with waves spawning near outposts. Asteroids frustrate. Huge asteroids come too early. https://mods.factorio.com/mod/warptorio-space-age/discussion/699b9b4dd380e7a3c7b47652
- Late game is slow, with waiting for research and warps, and the final battle is too easy and hurts UPS. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a143bbf51bed9392d282917
- The portal score is -15.63 (https://mods.factorio.com/api/mods/warptorio-space-age/full). I do not know how that score is computed, so I treat it as noise.

### Technical problems

- Multiplayer desync and forced-warp crash, fixed in 0.4.6 (2026-10-11). Game-over from a wrong surface check, fixed in 0.4.7. (changelog, API page)
- Train problems after warp, repeatedly: trains go to manual mode during warp, a combinator shows time until warp from the planet, not space, and the combinator output is 0 on a ground platform in space. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a76e4e89acc92b07674160c . Warp trains had a "complete rework" in 0.2.13.
- Spawn collisions: platforms from the past spawning on the player's platform, and demolishers spawning on the platform during height-limited warps. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a143bbf51bed9392d282917
- UPS: the author reduced wave-system UPS loss in 0.0.19 and changed final-research spawning for performance in 0.0.17; a 144 hour player says the final battle hurts UPS. (changelog; thread above)
- Circuit signals for the timer were added late. The combinator was a long-running request and stops updating after transitions. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a78b7dffef228be32ff6120 (the thread I read was titled "Combinator for Top Bar")
- Many hidden mechanics undocumented (accumulator circuit sharing, warp container cannot be picked up). https://mods.factorio.com/mod/warptorio-space-age/discussion/68b9ebed695f0a2b428f48e7

## Lessons for our mod

Each point cites the evidence above.

Timer design

1. Do not start the timer silently. Warptorio SA players lost stockpiles and thought the mod was broken when the timer or the first waves started without notice. Show a visible start message and a countdown from the first second. (https://mods.factorio.com/mod/warptorio-space-age/discussion/67cf9cf2db3541d6f0fb1885 , https://mods.factorio.com/mod/warptorio-space-age/discussion/67c083d41a041f506a7b5fd6)
2. Warn before the end. Players asked for a one minute alert, and the author added a 60 second warning plus an on-screen countdown only in 0.4.4. Ship staged alerts at launch (for example 5 minutes, 1 minute, 10 seconds) with sound, and show remaining time in the top bar. (https://mods.factorio.com/mod/warptorio-space-age/discussion/69938035d7b0a28a6ecf11b8 , changelog)
3. Make the loss of unsaved gains bounded. Tension works when the player can see what is at stake. Where Warptorio punishes, it takes the whole planet base. In our design the player's factory stays safe in orbit, so only the lander and the carried haul are at risk. This is our structural advantage over Warptorio. Keep the stakes to the haul, not to the factory.
4. Let research or upgrades extend the timer, but warn that more time is not free. In Warptorio SA longer timers meant more waves and ammo, so players did not want them. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a6e97aa32ff991e0ced2534 . If we extend the timer, the extra time should be safe time, not extra enemy time. Consider no enemies on the fleeting planets at all.
5. Do not let a player save the base by returning. Warptorio SA players asked to reset waves on revisit or to ban repeat visits, because revisits killed bases. Make every planet single-use and fresh. https://mods.factorio.com/mod/warptorio-space-age/discussion/6a6e97aa32ff991e0ced2534
6. Give a visible, early, optional "leave now" with a cost, not a hard fail. Players valued deciding when to leave (the original premise of Warptorio2, https://mods.factorio.com/api/mods/warptorio2/full). Make the forced end predictable (a countdown), not a surprise (the klaxon thread).
7. Expose the timer as circuit signals from release one. Warptorio SA added this late and had bugs (stops updating after transitions, wrong value in space). https://mods.factorio.com/mod/warptorio-space-age/discussion/6a76e4e89acc92b07674160c , https://mods.factorio.com/mod/warptorio-space-age/discussion/6a78b7dffef228be32ff6120
8. Tie the timer to Thud's take-off cost. Thud's soft take-off needs damper charge and the Jump efficiency research cuts it (https://mods.factorio.com/mod/Thud/changelog). Decide whether a forced take-off is free or draws on charge, and tell the player in advance. A player who cannot leave because charge ran out is a punishment, not tension.

Planets and pacing

9. Tell the player what the next planet offers before they commit. Warptorio's planet descriptions hint at traits, and loot chests reward short exploration. Players asked for manual next-planet choice. A visible next-planet preview with a choice of two gives tension from a decision. (https://mods.factorio.com/api/mods/warptorio2/full , https://mods.factorio.com/mod/warptorio-space-age/discussion)
10. Do not repeat the same planet twice in a row. Warptorio added this rule early (0.0.4) and tightened it later (0.2.9). (changelog)
11. Keep the early game short. Early game complaints dominate in Warptorio SA: long grace, silent timers, too little space. The 0.4.0 default of a shorter first-planet timer shows the author moved this way. (changelog; threads 67c083d41a041f506a7b5fd6 and 6a143bbf51bed9392d282917)
12. Avoid asteroid and logistics bottlenecks as the main resource path. The "limited options to push creative solutions" philosophy produced complaints about throughput and liquid logistics. https://mods.factorio.com/mod/warptorio-space-age/discussion/699b9b4dd380e7a3c7b47652 . Our bulk resources come from landings, so give the haul a simple, fast route to orbit.

Technical

13. Keep the landing site clear of the player's own loss. Thud destroys what is at the landing site. Make the generated planet's landing zone empty so the player never loses a base to the shadow. (https://mods.factorio.com/mod/Thud/changelog)
14. Plan for spawn collisions and cleanup. Warptorio SA spent many releases on platforms spawning on top of the player and on things left behind (0.3.5, 0.4.3, and others). Delete the temporary surface cleanly after take-off, and test in multiplayer from the start, since Warptorio's desyncs and forced-warp crashes lasted to 0.4.6. (changelog)
15. Do not copy Warptorio SA code. It is GPL and does not use Thud. Read its design notes, and use its public `edit_planet_variants` idea only as inspiration.
16. Document hidden mechanics in the mod page and in-game tips. Many Warptorio SA complaints were about unexplained rules. https://mods.factorio.com/mod/warptorio-space-age/discussion/68b9ebed695f0a2b428f48e7
17. Open question for the Thud author: does it accept custom or generated surfaces, does it have events, and what are the `thud` function names. Ask in https://mods.factorio.com/mod/Thud/discussion before we commit to the design.

## Gaps

- Thud remote function names, parameters and events: not readable (no repo, description gives no signatures).
- Thud thread bodies for "Platform Emergency Landing does not work", "few questions", "Aquilo Specifics", "Give us an option to disable trains and chests", "2.0.77 backport?": only titles loaded.
- Reddit threads and YouTube view counts: web search surfaced none. No numbers given.
- Official numeric warp timer values for Warptorio SA: only player reports (10 minutes auto-warp, bosses at 13 to 15 minutes). The changelog says the first-planet timer is shorter by default but gives no minutes.
- Why Warptorio2 stopped: unconfirmed.
