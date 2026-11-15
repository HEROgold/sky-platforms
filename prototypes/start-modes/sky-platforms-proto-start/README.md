# sky-platforms-proto-start

Throwaway prototype for Factorio 2.1 with Space Age. Do not release it.

## Question

Which start feels right: no body (remote controller), no body (god controller), or a character that walks on the platform and can step off it?

## Install

1. Copy or symlink this folder into `%APPDATA%\factorio\mods\` (for example as `sky-platforms-proto-start_0.0.1`).
2. Start Factorio 2.1 with Space Age and the mod enabled.
3. Start a new freeplay game. The mod skips the intro and crash site, creates a platform orbiting Nauvis, fills the hub, and starts you in remote mode.

## Commands

- `/sky-start <remote|god|walk>` switches your mode in place, so one save tests all three.
- `/sky-state` prints controller type, surface, position, whether a character exists, and whether handcrafting is possible.

Every API call prints its result or error to chat and to `factorio-current.log`. A failed call does not crash the mod.

## Hub contents

50 space-platform-foundation, 20 inserters, 20 assembling-machine-1, 10 solar panels, 4 asteroid collectors, 4 crushers.

## Notes

- God mode has its handcrafting categories emptied in `data-final-fixes.lua`. That is part of the test.
- Remote mode first switches to god to detach the old character, then destroys it. Expect side effects from that.
- Walk mode logs each tile type the character stands on. Nothing blocks it from walking past the platform edge.

## Test checklist

Run `/sky-state` at the start of each mode. Leave the results empty for the tester.

| Check | remote | god | walk |
| --- | --- | --- | --- |
| Build ghosts | | | |
| Place items from the hub | | | |
| Open machine GUIs | | | |
| Open the hub GUI | | | |
| Handcraft | | | |
| Inventory (open it, hold items) | | | |
| Map view | | | |
| Walk on the platform | | | |
| Step off the platform edge | | | |
| Save and reload | | | |
| Second player joins | | | |
| `/sky-state` output matches expectation | | | |
