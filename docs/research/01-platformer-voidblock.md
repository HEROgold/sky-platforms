# Research: Platformer and VoidBlock

Researched 2026-11-15. All claims cite a URL. Portal discussion pages show only relative dates ("1 year, 9 months ago") and no post bodies on the index, so thread dates are approximate. Reddit and forums.factorio.com searches returned nothing for either mod (web search surfaced only mod portal pages), so there is no reddit or YouTube evidence below. YouTube view counts were not checked.

## Factorio version today

- Factorio 2.1 is stable. Secondary sources say Wube marked it stable on 2026-10-23, current build 2.1.23, and call it the last major content update. Saves and blueprints cannot go back to 2.0. Sources: https://zap-hosting.com/en/blog/2026/10/factorio-2-1-is-stable/ and the search summary of https://accountshark.net/blog/factorio-2-1-stable-final-major-update-mixed-rockets-quality-toggle-biters-guide . I did not load the official changelog, so the exact build number is unverified.
- Target 2.1 for a new mod. Both mods below needed a 2.1 update or fork.

## Platformer

### Hard facts

| Item | Value | Source |
|---|---|---|
| Downloads | 6,601 | https://mods.factorio.com/api/mods/platformer/full |
| First release | 0.1.0 on 2024-12-01 | same |
| Last release | 1.0.6 on 2025-02-23, Factorio 2.0 only | same |
| Release count | 15 releases in about 12 weeks, then nothing | same |
| License | GNU GPLv3, so forking and reuse are allowed with the same license | same |
| Source repo | Portal API lists no source URL, only a Discord link. Local info.json names https://github.com/WinCor-Factorio/Platformer . | portal API, local info.json |
| Repo state | 175 commits, 2 stars, 1 open issue. Last commit date and license not shown on the page. | https://github.com/WinCor-Factorio/Platformer |
| Maintenance | Abandoned on the portal. Last release is about 1 year 9 months old, no 2.1 build. | https://mods.factorio.com/mod/platformer |

Descendants, which show demand persisted:
- Platformer (2.1 Fork) by xane256. 174 downloads, latest 1.3.8 about 2 months old, GPLv3, loads saves from the original. Source https://github.com/xane256/factorio-platformer . Page: https://mods.factorio.com/mod/platformer-fork
- Pooz Space Race, a modified continuation by Corlin and Xiroc adding a repeatable race and team play. https://mods.factorio.com/mod/pooz-space-race (seen in search results only, page not read).
- Space Platform Start, a separate mod where you start in the hub of a "Stranded platform" and cannot leave the hub. https://mods.factorio.com/mod/factorio-space-platform-start (search result summary only, page not read).

### How it works

- Skyblock in space. One platform, no planetary landing, resources come from asteroids, and each planet's asteroids give different resources. Hub chests send placeable items straight to the hub. https://mods.factorio.com/mod/platformer
- Character: the character still exists. Players report character handcrafting is enabled ("Character handcrafting enabled" thread), and one player opened the character GUI and handcrafted after visiting Nauvis. https://mods.factorio.com/mod/platformer/discussion/674ccbf3a83e0b6c233b917a
- Starting items: 1.0.0 "made the start harder with fewer items", 0.1.4 reduced starting crushers to 1. Items are crushed from asteroids, with distinct metallic asteroid crushing methods. Changelog in https://mods.factorio.com/api/mods/platformer/full
- Progression reaches other planets' resources via asteroid spawn definitions, not landing. 0.1.7 added Aquilo asteroid spawns plus fluorine, ammoniacal solution and lithium brine recipes. 1.0.5 removed the lose condition and carbonic asteroids. Same changelog.
- Dependencies from the local info.json: space-age, space-platform-chests, quality, elevated-rails (as given in the brief).

### What players liked

- "I was waiting for this": a player welcomed a space skyblock mod and noted the older Spaceblock mod predates Space Age. https://mods.factorio.com/mod/platformer/discussion/674ccbf3a83e0b6c233b917a
- A player who finished the mod praised its design before raising fluid and hub-inventory issues. https://mods.factorio.com/mod/platformer/discussion/679ad869c0f9c654c0016a61
- Author response was fast. Threads on blockers were answered and fixed within days, then locked. https://mods.factorio.com/mod/platformer/discussion/674dc6467e8e87e7a98fb399

### What players complained about

- Progression deadlocks at launch. Ice recipe never unlocked, blue science needs sulfur which needs water, white science needs carbon but carbonic asteroids did not spawn on Nauvis, and medium planet-specific asteroids split into vanilla types so the unique chunks could not be obtained. Author said these were fixed. https://mods.factorio.com/mod/platformer/discussion/674dc6467e8e87e7a98fb399
- Early power. A minimal red and green science setup used all available solar power, forcing a long wait. Same thread.
- Stone scarcity early because few Crudeic asteroids spawn. https://mods.factorio.com/mod/platformer/discussion/679e68f699654add68a35c75
- Fluid byproduct backups. Aquilo asteroids produce ammonia and fluorine, fluorine backs up, and there is no way to void fluids. https://mods.factorio.com/mod/platformer/discussion/679ad869c0f9c654c0016a61
- Hub inventory floods when removing buildings, with no automated way to return items without logistic bots. Same thread.
- Tech tree pruning removed vanilla techs it judged "no effect" (modules, trigger techs, Bob's inserter research), and unbuildable items stayed in the tree (boilers, electric miners, steel furnaces). https://mods.factorio.com/mod/platformer/discussion/679e68f699654add68a35c75 and https://mods.factorio.com/mod/platformer/discussion/674ccbf3a83e0b6c233b917a
- Items sent down via the trash slot left a drop pod notification that never cleared. First impressions thread above.
- Missing items and research, from thread titles on https://mods.factorio.com/mod/platformer/discussion : missing iron chests, train braking force research disabled while trains are enabled, "Techs without use", "Bob's Logistics Incompatibility", and "Request: option/compat with Modular Turrets". Titles only, bodies not read except where cited.

### Technical problems

- A possible multiplayer desync with Hub chests, fixed in 1.0.4. Changelog in the portal API link above.
- Mod compatibility: Bob's Logistics and Bob's Adjustable Inserters conflicts (titles on the discussion index). Heavy tech pruning and removed surface conditions are the likely cause, but that is my inference.
- Performance and save breakage: not mentioned anywhere I could read.

### Why it went stale (inference, not stated by anyone)

No source gives a reason. Facts: bursts of 15 releases in 12 weeks, last release 2025-02-23, no 2.1 build from the authors, and a third party forked it for 2.1. The mod rewrote the tech tree and recipes broadly, which makes every Space Age change a re-balance. Treat this as a hypothesis.

## VoidBlock

Note: VoidBlock is not a space platform mod. It is an island-and-void overhaul. It is relevant for "start with almost nothing", a custom start, and how planets are treated.

### Hard facts

| Item | Value | Source |
|---|---|---|
| Downloads | 13,335 | https://mods.factorio.com/api/mods/VoidBlock/full |
| First release | 1.0.0 on 2024-11-28 | same |
| Last release | 1.2.3 on 2026-09-22, Factorio 2.1 | same |
| Releases | 39 total. 1.1.20 on 2026-05-08 was the last 2.0 build, 1.2.0 on 2026-07-26 the first 2.1 build. | same |
| License | GNU GPLv3, forking allowed with the same license | same |
| Source repo | Portal lists only a Discord link, no source URL | same |
| Maintenance | Active. The author S6X replies to most threads. | https://mods.factorio.com/mod/VoidBlock/discussion |
| Companion mods | Designed to work with Voidcraft, Iridescent Industry, Bluetonium, Scrappy Industry, Crushing Industry | portal API |

### How it works

- New game required. You start on an island in a void ocean with only a voidshed. Voidcraft gives stone, metal and landfill. Landfill is 20 stone and 40 seconds. Other planets are also islands, foundation and ice platform costs are reduced, and an option removes almost all surface restrictions so you may not need to leave your starting planet. https://mods.factorio.com/mod/VoidBlock
- Early game is slow and RNG dependent. Voidsheds make basic resources, a sushi belt of stone furnaces helps, and only voidforges make voidcraft science packs. https://mods.factorio.com/mod/VoidBlock/discussion/67486353ccdc34c7d875b96f
- Landing on planets: a setting exists so other planets are not void-block (author can limit Void Block to Nauvis). https://mods.factorio.com/mod/VoidBlock/discussion/6a2d20ff70ecb2568cd20895

### What players liked

- "good mod", praise for the concept. https://mods.factorio.com/mod/VoidBlock/discussion/67486353ccdc34c7d875b96f
- Praise for the graphics (thread "Praise for the graphics, and change log request"). Title on https://mods.factorio.com/mod/VoidBlock/discussion
- One player liked sorting the voidshed's random output and its zero fuel or power cost. https://mods.factorio.com/mod/VoidBlock/discussion/67a537097aead5e89c502ae5

### What players complained about

- Balance. Players said voidtronic recipes cost too much power and footprint, and they mostly void basic resources. The author said they kept voidcraft weak on purpose. https://mods.factorio.com/mod/VoidBlock/discussion/6753175599b0b1d74d90d965
- Landing on other planets was the most replied bug thread (16 replies). One search summary says a player landed in lava because terrain replacement removed the spawn tiles. Thread listed on https://mods.factorio.com/mod/VoidBlock/discussion . Body not read, summary came from web search.
- Water and electricity confusion. Threads "Unable to make water", "Can not get water" style, and "Electrification" (13 replies). Titles on the discussion index.
- Landfill cost too high (thread "Landfill Too Expensive"), now an adjustable setting per the portal description.
- Requests for a non-block mode, answered with "use Voidcraft with low resource sliders". https://mods.factorio.com/mod/VoidBlock/discussion/67a537097aead5e89c502ae5
- Unclear endgame or win condition (two threads, "Endgame Goal" and "End / win condition"). Titles only.

### Technical problems

- Mod conflicts. LithiumBattery fails to load on a recipe category error. The author refuses to patch it to avoid late-game softlocks and points to a Nauvis-only setting. https://mods.factorio.com/mod/VoidBlock/discussion/6a2d20ff70ecb2568cd20895
- Other conflicts by title: Castra, Bob's items, Blueprint Shotgun errors, "consistent crash", "Non rec error on worldgen".
- Existing saves: chunks generate as ocean, "it will look strange". https://mods.factorio.com/mod/VoidBlock
- 2.1 migration was reported as an on-load error ("Erron onload with 2.1", 4 months ago) and fixed in 1.2.x. Titles on the discussion index and releases in the portal API.
- Performance and multiplayer: not mentioned in anything I could read.

### Why it stayed alive (inference)

One author who answers threads, ships small frequent patches (39 releases), updated to 2.1 within about 3 months of the 2.1 experimental branch, and sits on a small ecosystem of companion mods. Treat this as a hypothesis from the release data above.

## Lessons for our mod

1. Target Factorio 2.1 from day one and keep the changes small. Platformer stalled on 2.0 and needed a third-party fork (https://mods.factorio.com/mod/platformer-fork). VoidBlock updated for 2.1 and kept downloads growing (https://mods.factorio.com/api/mods/VoidBlock/full).
2. Do not rewrite the tech tree or remove surface conditions. Platformer's pruning removed vanilla techs and left unbuildable items in the tree, and every Space Age change meant re-balancing (https://mods.factorio.com/mod/platformer/discussion/679e68f699654add68a35c75). VoidBlock refused to patch recipe-rewrite conflicts to avoid softlocks (https://mods.factorio.com/mod/VoidBlock/discussion/6a2d20ff70ecb2568cd20895). Our minimal-vanilla goal avoids both.
3. Script a progression walk before release. Platformer's launch had a circular dependency chain (ice, sulfur, water, carbon) that blocked players within days (https://mods.factorio.com/mod/platformer/discussion/674dc6467e8e87e7a98fb399). For us, check that every planet visit can supply what the next tech needs, including if a timer expires early.
4. Give the opening a tested power and stone path. Players hit early solar limits and stone scarcity in Platformer (same thread, https://mods.factorio.com/mod/platformer/discussion/679e68f699654add68a35c75). Our starting platform needs a guaranteed first supply of stone, iron, copper and power.
5. Provide a way to void fluids and surplus items, and a way to return deconstructed items. Platformer players asked for both (https://mods.factorio.com/mod/platformer/discussion/679ad869c0f9c654c0016a61). VoidBlock added a throw-junk-in-the-ocean setting that players liked (search summary of https://mods.factorio.com/mod/VoidBlock/discussion).
6. Decide the character question explicitly. Platformer left the character with handcrafting and the GUI opened when returning from a planet, breaking the intended play (https://mods.factorio.com/mod/platformer/discussion/674ccbf3a83e0b6c233b917a). A no-body start must disable handcrafting and remote-view edge cases.
7. Do not let temporary-planet content break landing. VoidBlock's landing bug was its most-discussed (16 replies, https://mods.factorio.com/mod/VoidBlock/discussion) and terrain replacement was blamed in a summary. Our fleeting planets should use vanilla generation and a safe landing and return-to-orbit path.
8. State the goal. VoidBlock players asked what the endgame is (https://mods.factorio.com/mod/VoidBlock/discussion). Platformer removed its lose condition in 1.0.5 (changelog in the portal API). Tell players the win and lose conditions in the mod description, in particular what happens when a planet timer expires.
9. Add a mod-settings escape hatch, not hard-coded changes. VoidBlock's Nauvis-only and surface-restriction options answered conflict and "non-block" requests (https://mods.factorio.com/mod/VoidBlock/discussion/6a2d20ff70ecb2568cd20895 and https://mods.factorio.com/mod/VoidBlock/discussion/67a537097aead5e89c502ae5).
10. Plan for multiplayer early. Platformer shipped a Hub chest desync fix in 1.0.4 (portal API). Test any on-timer planet creation and remote transfers in multiplayer.
11. Stay maintained and answer threads. Platformer's fast author replies earned praise, but releases stopped after 12 weeks. VoidBlock's steady patching is the contrast (release lists in both portal API links).
12. Use GPLv3-compatible reuse. Both mods are GPLv3, so ideas and code from Platformer's asteroid and hub-chest handling can be reused if our mod is GPLv3 too. Check the repo license file before copying code, since the GitHub page did not show one.

## Gaps

- No reddit, forums.factorio.com, or YouTube data found for either mod.
- Discussion post bodies were read only for the threads cited. Others are title-only.
- Platformer GitHub README, issue, and commit dates were not visible. Portal API listed no source URL.
