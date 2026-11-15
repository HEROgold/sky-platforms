# Phase 0 research summary

Researched 2026-11-15. The details and source links are in files 01 to 03. Sources marked "search summary only" in those files were not read in full. Reddit and forums.factorio.com blocked the research agents, so there is no community vote data.

## Facts that shape the design

- Factorio 2.1 went stable on 2026-10-23. Thud only runs on 2.1, so we target 2.1 only.
- Thud lands the whole platform on the planet below. Nothing else in the loop does. Our idea, where the factory stays in orbit and something goes down, means either landing a small dedicated lander platform or landing the main platform itself. This is the first design decision.
- Thud is MIT, has 462 downloads, appeared on 2026-10-11 and has no public source repo. Its `thud` remote interface arrived on 2026-11-15 (version 2.2.0). We have not read its function names yet. Depending on a young single-author mod is a risk, so we keep the integration in one module.
- No existing mod combines a space start with timed, temporary landings. Space Platform Start (426 downloads) has the start but no reason to go down. Warptorio Space Age (14.4k) has the timer but starts on the ground.
- Platformer (6.6k, GPLv3) and Warptorio Space Age (GPL) cannot be copied into a non-GPL mod. We take ideas, not code, unless we pick GPL.

## What players praised and punished

- Platformer: the authors fixed launch softlocks within days, which won goodwill. The softlocks were missing stone, an ice and sulfur loop, and too little power. It also pruned vanilla techs, which players disliked. Its code destroys the character at start (`control/init.lua:18-20`), but 01 reports handcrafting and a character GUI after a Nauvis visit. That conflict needs an in-game check (see 06-bodiless-start.md).
- Warptorio: the timer creates good tension, but players hated a timer that starts silently, warps with no warning, and destroys builds. Staged alerts only came late, in 0.4.4.
- VoidBlock: settings answered most feature requests. Its biggest bug thread was about landing on other planets.

## Lessons we adopt

1. Show the planet timer from the first second, with staged alerts, and expose it as circuit signals.
2. The timer costs you the haul, never the orbiting factory.
3. Each planet is fresh and single-use, so losing one is expected, not a failure.
4. Script-test the first hour for softlocks: power, stone, water and the first landing.
5. Leave the vanilla tech tree alone, except for what the start strictly needs.
6. Disable handcrafting and the character for a true bodiless start.
7. Test multiplayer and save loading from the first slice.
8. Launch on 2.1 in the Overhaul or Content category, with a thumbnail, captioned screenshots and a clear win and lose condition. Recorded runs by YouTubers drove Warptorio downloads.

## Open questions

- Lander platform or main platform landing (design).
- Thud's remote interface: function names, events and size limits (research, read the mod zip).
- Which planets can be generated, and whether temporary surfaces cost too much script time (research).
- License: GPL, so we could reuse Platformer or Warptorio code, or MIT to match Thud.
