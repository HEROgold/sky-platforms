# Market and marketing research: space-start, temporary-planet Factorio mod

Date of research: 2026-11-15. Mod download counts come from `https://mods.factorio.com/api/mods/<name>/full`, fetched on that date. "Rate" is downloads per day since first release, my own calculation. The portal counter may include update downloads, so treat rates as rough.

## Gaps in the evidence (read first)

- forums.factorio.com returned HTTP 403 to every fetch, from both the web tool and curl. Forum threads below are cited from search-result summaries only, not read in full. Reply counts and views are unknown.
- reddit.com is blocked in this environment, and searches surfaced no r/factorio threads. Part B has no Reddit upvote counts. Nothing here claims Reddit demand.
- stevivor.com (the 2.1 stable report) returned 403. The 2.1 facts rest on a search summary plus portal data (see Factorio version).
- I found no source for Friday Facts mentions of any mod in this niche. I do not claim any.
- I could not verify which big YouTubers cover this niche. Only the creators named in Part C are confirmed.

## Factorio version

- Current stable looks like 2.1, not 2.0. A search summary citing [Stevivor](https://stevivor.com/news/factorio-2-1-goes-stable-as-wube-software-wraps-up-major-updates/) (not loadable, 403) and [Heise](https://heise.de/-11313123) says 2.1 reached stable on 23 October 2026 and is the last major update, with modding support as the continuing focus.
- Corroboration from the portal API, which I did read: Thud's latest release is 2.1.0 for Factorio 2.1 (2026-10-11), and Planet Crafter: Nauvis Reborn requires "Factorio 2.1.22+" ([Thud](https://mods.factorio.com/mod/Thud), [Planet Crafter](https://mods.factorio.com/mod/planet-crafter-nauvis)). Many older mods now list 2.0 to 2.1.
- Modder-facing changes per the 2.1.18 changelog, via search summary only ([forum changelog](https://forums.factorio.com/viewtopic.php?p=703893), not loadable): a `migrates_from` field in info.json lets a mod take over storage, GUI elements and render objects from a removed mod; new `science_capacity` prototype fields; rocket silo weight capacity is modifiable; Quality is no longer a hard dependency of Space Age. The [wiki upcoming features page](https://wiki.factorio.com/Upcoming_features) lists more. I did not read it.
- Implication: ship a 2.1 build first. Space Platform Start already lists 2.0 to 2.1 ([page](https://mods.factorio.com/mod/factorio-space-platform-start)), so 2.1-only is not required, but Thud's newest build targets 2.1.

## Part A: comparable mods

| Mod | Portal | Downloads | First / last release | Rate |
|---|---|---|---|---|
| Space Platform Start | [link](https://mods.factorio.com/mod/factorio-space-platform-start) | 426 | 2026-08-01 / 2026-08-22 | about 4 |
| Space Together | [link](https://mods.factorio.com/mod/space-together) | 109 | 2026-09-29 / 2026-10-06 | about 3 |
| Aquilo Orbit Start | [link](https://mods.factorio.com/mod/aquilo-orbit-start) | 51 | 2026-09-27 / 2026-10-12 | about 2 |
| Warptorio 2.0 (Space Age) | [link](https://mods.factorio.com/mod/warptorio-space-age) | 14,423 | 2025-02-18 / 2026-10-27 | about 23 |
| Any Planet Start | [link](https://mods.factorio.com/mod/any-planet-start) | 42,604 | 2024-10-18 / 2026-11-13 | about 56 |
| Planet Picker | [link](https://mods.factorio.com/mod/planet-picker) | 5,814 | 2024-11-05 / 2026-09-22 | about 8 |
| Void Block | [link](https://mods.factorio.com/mod/VoidBlock) | 13,335 | 2024-11-28 / 2026-09-22 | about 19 |
| Space Age Without Space | [link](https://mods.factorio.com/mod/SpaceAgeWithoutSpace) | 6,105 | 2024-11-21 / 2026-10-29 | about 8 |
| Space Is Fake | [link](https://mods.factorio.com/mod/space-is-fake) | 4,877 | 2026-07-25 / 2026-11-15 | about 43 |
| Nauvis Implosion and Gehenna | [link](https://mods.factorio.com/mod/nauvis-implosion) | 466 | 2024-12-08 / 2024-12-10 | dead |
| Semi-procedural Systems | [link](https://mods.factorio.com/mod/procedural-systems) | 810 | 2025-03-12 / 2025-08-10 | about 2 |
| Planet Rubia | [link](https://mods.factorio.com/mod/rubia) | 45,784 | 2025-05-14 / 2026-11-12 | about 83 |
| Metal and Stars | [link](https://mods.factorio.com/mod/metal-and-stars) | 33,841 | 2025-01-18 / 2026-07-04 | about 51 |
| Space Age Hard Mode | [link](https://mods.factorio.com/mod/Space-Age-Hardcore-Mode) | 3,674 | 2024-11-19 / 2026-05-28 | about 5 |
| Thud (comparison) | [link](https://mods.factorio.com/mod/Thud) | 462 | 2026-10-11 / 2026-11-15 | about 13 |

Looked up and left out: Platformer is not on the portal under that exact name (the API returned "Mod not found"). Team Starts for Multiplayer (1,196 downloads, last release 2024-10-27) and JJtorio (103 downloads, alpha) are less relevant.

### Hooks and why each did or did not take off

**Direct competitors (space or platform starts).**

- **Space Platform Start** (phiresky). Hook: "Start on a stranded space platform. Minimal changes to make it possible to win the game this way." You start in the hub, cannot leave it, and the platform sits at a planetless point in Vulcanus orbit. Starting items are an asteroid collector, crusher, four furnaces, assembler and two solar panels. Damaging asteroids become collectible chunks for the first 60 minutes. Source: [mod page](https://mods.factorio.com/mod/factorio-space-platform-start). Why it is small: it is 3.5 months old, sits in the Scenarios category, and has two uncaptioned screenshots. The API shows a highlight on 2026-09-14 and it still has only 426 downloads, so a weekly highlight alone did not move it. The category and sparse page as causes are my inference. It has no landing or temporary-planet loop, so it is the closest existing mod but not the same game.
- **Space Together** (multiplayer fork of the above). Hook: you do not start on a planet, you get resources from asteroids, then fly to your first planet. It has a time limit that only runs while a team member is online (search summary of the [page](https://mods.factorio.com/mod/space-together); I did not read the mechanic myself). 109 downloads in about 6 weeks. It cannot be enabled with the single-player mod.
- **Aquilo Orbit Start** (thejoshwolfe). Hook: "Start on a space platform above Aquilo", built to work with the Archipelago randomizer ([page](https://mods.factorio.com/mod/aquilo-orbit-start)). 51 downloads. Small audience by design.
- **Any Planet Start** (_CodeGreen). Hook: start on Vulcanus, Gleba or Fulgora via a startup setting, works with many modded planets. 42,604 downloads, the largest alternative-start mod found. Its first release (2024-10-18) came three days before Space Age launched (the launch date is from my own knowledge, not a fetched source). Why it took off: launch timing, a one-sentence promise, and compatibility with planet mods. A user asked the author about starting in space. The author replied that it is not something he wants to include and "This mod is meant for starting on planets, not in space" ([discussion](https://mods.factorio.com/mod/any-planet-start/discussion/6990e421218c472428ce38b7)). That is both a demand signal and a vacancy signal.
- **Planet Picker** (Nimphious). Hook: pick a starting planet, per player in multiplayer, works with modded planets. 5,814 downloads. Weekly Highlights featured it on 2024-12-09 ([highlights page](https://mods.factorio.com/highlights/2024-12-09)). Its author says Any Planet Start is probably the better choice for a polished single-planet start ([Planet Picker discussion](https://mods.factorio.com/mod/planet-picker/discussion/672ab2a16f7fa6a3834672ee), search summary). A reviewer there reports that starts on Fulgora and Vulcanus can leave the player without water or power. Early-game softlocks are a known risk for non-vanilla starts.

**Roguelite, timed, warp-style.**

- **Warptorio 2.0 (Space Age)** (Venca123). Hook: "Build your base on a platform that warps from planet to planet and escape biters before they overwhelm you." 14,423 downloads, highlighted 2026-09-21. Category Overhaul. The page has a Discord link, a "Hall of fame" of 7 completed YouTube runs, an 8-step guide for adding planet variants, and a thumbnail plus three screenshots ([page](https://mods.factorio.com/mod/warptorio-space-age)). Why it works: a known predecessor, a clear failure state, and recorded runs as proof. Reviewers say they began after watching a YouTube video, and some call the midgame grindy ([discussion](https://mods.factorio.com/mod/warptorio-space-age/discussion), search summary). A fork, Warptorio 2.1 (edge), exists ([page](https://mods.factorio.com/mod/warptorio-space-age-edge)). Do not compete on the warp loop.
- **Void Block** (S6X). Hook: "Start with nothing, build everything." 13,335 downloads, highlighted 2026-02-23. The title is the pitch. A stream by The7swords exists (search summary, [page](https://mods.factorio.com/mod/VoidBlock)).
- **Nauvis Implosion and Gehenna.** Hook: a countdown destroys Nauvis and changes the game loop. Two releases in December 2024, 466 downloads, no 2.1 build ([page](https://mods.factorio.com/mod/nauvis-implosion)). The API shows a highlight on 2026-04-27, which did not revive it. A timer idea with no ongoing updates built no audience.
- **Semi-procedural Systems.** Hook: a framework for procedurally generated systems, currently one system with 6 planets. 810 downloads, last release 2025-08-10. The page itself says it needs playtesting and balancing ([page](https://mods.factorio.com/mod/procedural-systems)).

**Planet and compression mods (audience reference).**

- **Planet Rubia**: 45,784 downloads, about 83 per day, the best rate in the set. Hook: a wind planet where belts and inserters behave differently. Highlighted 2026-07-13. Players praise it, with complaints about script time (UPS) and softlocks with other mods ([discussion](https://mods.factorio.com/mod/rubia/discussion), [changelog](https://mods.factorio.com/mod/rubia/changelog), search summaries).
- **Metal and Stars**: 33,841 downloads. Hook: other ways to leave the solar system, with new destinations and machines. Highlighted 2025-10-20 ([page](https://mods.factorio.com/mod/metal-and-stars)).
- **Space Is Fake**: 4,877 downloads in 113 days (about 43 per day), updated today ([page](https://mods.factorio.com/mod/space-is-fake)). Hook: Space Age compressed onto Nauvis.
- **Space Age Without Space** (6,105) and **Space Age Hard Mode** (3,674) show steady but modest demand for rule changes to Space Age ([Without Space](https://mods.factorio.com/mod/SpaceAgeWithoutSpace), [Hard Mode](https://mods.factorio.com/mod/Space-Age-Hardcore-Mode)). "No Space Platforms" has 1,657 ([page](https://mods.factorio.com/mod/Space-Age-Without-Platforms)).

### What Part A says

- Existing space starts (Space Platform Start, Space Together, Aquilo Orbit Start) are all under four months old and total under 600 downloads. Demand is unproven, but the slot is not empty.
- None has the loop in this concept: temporary timed planets you land on for bulk or special resources. A search summary of forum threads reached the same conclusion ([p=693620](https://forums.factorio.com/viewtopic.php?p=693620), not loadable).
- Planet-content mods with one clear mechanic (Rubia, Metal and Stars) run about 50 to 80 downloads per day. Start-variant mods run about 2 to 56.

## Part B: what players want

The strongest evidence is on mod pages, not Reddit or the forum.

1. A user on Any Planet Start asked: "Have you given any thought to the prospect of starting in space instead of on a planet?" The author answered: "This mod is meant for starting on planets, not in space." Source: [discussion](https://mods.factorio.com/mod/any-planet-start/discussion/6990e421218c472428ce38b7). It was posted about nine months ago per the page's relative timestamp. Portal comments have no vote counts.
2. Another suggestion on Any Planet Start, per a search summary: start in a safe orbit with a few starter machines, and require extra science packs for later landings ([discussion](https://mods.factorio.com/mod/any-planet-start/discussion/6733591be8af520202274d67)). The author declined because starting in space needs very different code.
3. Forum thread "Allow creating space platforms at any space-location" ([p=650394](https://forums.factorio.com/viewtopic.php?p=650394), not loadable). Per the search summary, a space-platform-start mod author wants it so that reaching a planet can be the first challenge. Reply and view counts unknown.
4. Forum thread "No Crash Start" ([p=692780](https://forums.factorio.com/viewtopic.php?p=692780), [p=692771](https://forums.factorio.com/viewtopic.php?p=692771), not loadable). Per a search summary, it proposes one evolving mothership inspired by Warptorio, with research only possible on the ship. The Mod Ideas board listed one reply from Bunzli and a later post by Osmo, so interest is thin.
5. A forum post on platform-only play ([p=693620](https://forums.factorio.com/viewtopic.php?p=693620), not loadable, search summary) describes each landing as a race to secure useful resources, build a temporary beachhead and leave before being overwhelmed, with evolution rising fast after landing. This matches the concept closely. I did not read the original post or its author.
6. Older threads: "Space platform themed Factorio game mode (maybe endgame?)" ([p=132905](https://forums.factorio.com/viewtopic.php?p=132905)) and a 2023-era thread about starting on a platform that was moved from suggestions to mod requests. Not read in full.
7. A counter-signal: part of the audience wants fewer platforms, shown by "No Space Platforms" and "Space Age Without Space" above. A platform start should keep platform chores light.
8. Steam discussions surfaced only general Space Age comments ([example](https://steamcommunity.com/app/427520/discussions/0/4361250086037229367), search summary).

Not found: any Reddit post with upvote counts asking for this. I do not know whether one exists.

Demand read: modest, and mostly from modders and mod-page commenters. The signal is that "start in space" is a known wish that the biggest alternative-start mod declines to serve.

## Part C: how mods get marketed

Strongest evidence first.

**1. Timing relative to a DLC or major version.** Any Planet Start, Planet Picker, Void Block, Space Age Without Space and Space Age Hard Mode all first released between 2024-10-18 and 2024-11-28, within weeks of Space Age. All still lead their sub-genres on downloads. The 2.1 stable release (about 2026-10-23) may open a smaller version of that window. The newest mods (Space Is Fake, Planet Crafter, Thud) all launched in the last four months. This is inference from release dates, not a stated cause.

**2. Weekly Highlights and tags.**
- The Weekly Highlights page picks several tag categories and 5 mods each ([2024-12-09 example](https://mods.factorio.com/highlights/2024-12-09)). Planet Picker appears there under "Environment".
- Per the 2023 preview posts (search summary, [thread](https://forums.factorio.com/viewtopic.php?p=581207), not loadable), mods without a thumbnail, Internal-category mods, deprecated mods and mods incompatible with the current version are excluded.
- A highlight alone is not enough. Space Platform Start was highlighted on 2026-09-14 and has 426 downloads. Nauvis Implosion was highlighted on 2026-04-27 and is dead. Both are API `last_highlighted_at` values.
- The portal caches heavily, so new mods and updates can take hours to appear in listings ([trending page](https://mods.factorio.com/trending), search summary).
- Warptorio uses category Overhaul with Logistics, Combat, Enemies, Environment and Power tags. Space Platform Start uses Scenarios with Planets and Environment, plus Skyblock, Spaceblock and Seablock.

**3. Description and gallery.**
- Warptorio opens with a one-line tagline, then feature bullets, a Discord link, a modder guide and a Hall of fame ([page](https://mods.factorio.com/mod/warptorio-space-age)).
- Space Platform Start lists mechanics in detail but shows two uncaptioned screenshots ([page](https://mods.factorio.com/mod/factorio-space-platform-start)).
- I found no data showing that thumbnails raise downloads. The one rule I can cite is that a mod needs a thumbnail to be highlighted.

**4. YouTube and streamers.**
- Warptorio's Hall of fame lists complete runs by ラスコーリニコフ ([Japanese run](https://www.youtube.com/watch?v=GOjzMlwYUSw&list=PLblPwPAyrytjkWXMAbRMnU8pkf4HP4uPK)), Pettan ([1st](https://www.youtube.com/watch?v=l3_ZGQYay7I&list=PLLbp7fe0RMzvBMStSZUobamHSBocj8vVb&pp=0gcJCbAEOCosWNin), [2nd](https://www.youtube.com/watch?v=ndCnOsOazMI&list=PLLbp7fe0RMzucV0ctakqB5JhuzFLKOfxZ&pp=0gcJCbAEOCosWNin), [3rd](https://www.youtube.com/watch?v=jjjeLazlgdE&list=PLLbp7fe0RMzvTFH7ss4zfYV9R15jOHeJ3)), JohnMegacycle ([run](https://www.youtube.com/watch?v=UB9UMmoqEB8&list=PLYhuQUmCiA-CCf7KEK47ofUq3qee3LPht)) and Eggsceptional ([1st, "I was NOT ready for Warptorio 2: Space Age"](https://www.youtube.com/watch?v=MPK-nKyrwgk), [2nd](https://www.youtube.com/watch?v=zPgBz-tGhnY)). A portal commenter says they started the mod after a video by "some egg dude" (search summary of the [discussion](https://mods.factorio.com/mod/warptorio-space-age/discussion)), which I take to be Eggsceptional but did not confirm. Pettan's playlist runs 61 hours 54 minutes ([playlist](https://www.youtube.com/playlist?list=PLLbp7fe0RMzvBMStSZUobamHSBocj8vVb)).
- Void Block: The7swords streamed it (search summary, [VoidBlock page](https://mods.factorio.com/mod/VoidBlock)). A "Space Block" gameplay series exists but I did not identify the channel ([playlist](https://www.youtube.com/playlist?list=PLkHfUAaH9nIcXwNrrQlqDrXFsVxuIhvB_)).
- I did not confirm coverage by large channels such as Nilaus or Xterminator. A search naming them returned nothing relevant. Do not assume they cover it.
- Pattern: mods with recorded full runs have a failure condition and an end goal, which gives a streamer an episode arc. Planet Picker has neither and shows no such videos in my results.

**5. Discord.** Warptorio links a Discord server with a Warptorio channel ([invite](https://discord.gg/rUcDrB84y8), from its [page](https://mods.factorio.com/mod/warptorio-space-age)). I have no evidence of how many downloads Discord drives.

**6. Reddit and Friday Facts.** No evidence for either in this niche. Do not budget on Friday Facts.

### Three launches compared

| Mod | What it did | Result |
|---|---|---|
| Any Planet Start | Shipped three days before Space Age, one setting, works with modded planets | 42,604 downloads, updated 2026-11-13 |
| Warptorio Space Age | Known name, clear lose condition, planet-variant guide, Discord, Hall of fame | 14,423 downloads, highlighted 2026-09-21, forks exist |
| Space Platform Start | Detailed mechanics, Scenarios category, two screenshots, no landing loop | 426 downloads in 3.5 months despite a highlight |

## Recommendations

### Positioning

Pitch options, each with its backing.

1. "Start as a platform with no body, build a factory in orbit, and land on planets that last only minutes to grab uranium and rare resources." Backing: nobody offers timed landings (Part A), and a forum poster describes this loop as a race to secure resources and leave ([p=693620](https://forums.factorio.com/viewtopic.php?p=693620), search summary).
2. "Space Platform Start, but with a reason to go down." Backing: the existing mod has 426 downloads and no landing goal. This matches the search term players already use.
3. "Warptorio for people who want vanilla machines." Backing: Warptorio has 14,423 downloads, but some players call the midgame grindy. Risky if it reads as a copy.
4. "Vanilla Space Age, minus the planet start." Backing: Space Is Fake reached about 43 downloads per day with a close-to-vanilla angle ([page](https://mods.factorio.com/mod/space-is-fake)).

Use option 1 as the tagline and option 2 in the first paragraph.

### Launch checklist

- [ ] Ship a 2.1 build first and set compatibility to include 2.1. Planet Crafter and Thud show 2.1 authors are active ([evidence](https://mods.factorio.com/mod/planet-crafter-nauvis)).
- [ ] Choose Overhaul or Content, not Scenarios. Add Planets, Environment, Enemies and Combat tags where honest. Evidence: highlights are tag-driven, and Warptorio (Overhaul) outdrew Space Platform Start (Scenarios).
- [ ] Add a real thumbnail. Mods without one are excluded from highlights (2023 preview post, search summary).
- [ ] Write a one-line tagline, then a bulleted loop (start, build, land, timer, leave), then the starting items. Copy Warptorio's structure ([page](https://mods.factorio.com/mod/warptorio-space-age)).
- [ ] Caption three or more screenshots, including a landing and a timer shot. Space Platform Start's two uncaptioned shots are the counter-example.
- [ ] Name Thud as a dependency in the description with a link. Check compatibility with Space Platform Start and Space Together (those two already conflict with each other).
- [ ] Make the first hour survivable. Space Platform Start's 60-minute asteroid grace period and the water-and-power softlocks reported on other planet starts both point to this ([page](https://mods.factorio.com/mod/factorio-space-platform-start), [Planet Picker discussion](https://mods.factorio.com/mod/planet-picker/discussion/672ab2a16f7fa6a3834672ee)).
- [ ] Give the run a win and a loss condition so a streamer has an episode arc. Evidence: Warptorio's recorded runs.
- [ ] Open a Discord channel or join an existing one and link it on the page.
- [ ] Add a Hall of fame section from day one. Pettan and Eggsceptional have covered Warptorio. Nothing verifies they would cover another mod.
- [ ] Release within weeks of the 2.1 stable window. The 2024 cohort suggests the first weeks after a major version matter most (inference from release dates).
- [ ] Post once on r/factorio and the forum Mod Releases board. I have no evidence of effect, so keep it cheap.
- [ ] Publish a changelog with each patch. Any Planet Start, Rubia and Space Is Fake keep releasing and keep the higher rates.

### Risks to avoid

- Overlap with Space Platform Start and Warptorio. Differentiate on the timed landing loop in the first sentence. Evidence: Part A.
- Thin engine support. A forum request for platforms at any space location exists ([p=650394](https://forums.factorio.com/viewtopic.php?p=650394), search summary), and the Any Planet Start author said starting in space needs very different code. Test the bodiless start on 2.1 before promising it.
- First-hour softlocks, a common complaint on Planet Picker and Rubia ([Planet Picker discussion](https://mods.factorio.com/mod/planet-picker/discussion/672ab2a16f7fa6a3834672ee), [Rubia changelog](https://mods.factorio.com/mod/rubia/changelog)).
- Performance. A Rubia reviewer reported high script time in large saves. Temporary planets create and delete surfaces, so profile early.
- Abandonment. Nauvis Implosion has the closest idea (a countdown), two releases, and was highlighted in 2026 with no update ([page](https://mods.factorio.com/mod/nauvis-implosion)). Plan for updates.
- A dependency with a small base. Thud has 462 downloads. Say exactly what it does, with a link, so first-time visitors do not bounce.
- Overestimating demand. Direct demand is a few comments and forum posts. Against the closest mods, expect hundreds to low thousands of downloads in the first months unless a streamer picks it up. That range is my estimate from Part A, not a sourced number.

## Open questions

- Real r/factorio and forum demand with counts. Needs a session that can load both sites.
- Whether Friday Facts ever mentioned Warptorio, Any Planet Start or Rubia.
- Whether large mod-focused YouTubers have covered any space-start mod.
- What the 7 entries on the Space Platform Start discussion say about missing features ([thread](https://mods.factorio.com/mod/factorio-space-platform-start/discussion/6aba47495f60b80f46a27002), not read).
