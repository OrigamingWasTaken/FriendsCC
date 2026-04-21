# FriendsCC Monorepo Design Spec

Personal CC:Tweaked 1.21.1 development monorepo. Enables Claude Code to write correct, API-accurate Lua code for CC:Tweaked and its addons through a CLAUDE.md chain + LuaLS type stubs.

## Supported Mods

| Mod | Peripheral / API | Source |
|-----|-----------------|--------|
| CC:Tweaked (core) | turtle, redstone, rednet, peripheral, fs, http, os, term, window, textutils, colors, settings, shell, multishell, gps, paintutils, parallel, keys, disk, pocket, io, vector; peripherals: monitor, modem, speaker, printer | https://tweaked.cc/ |
| CC:Sable | `aero` API (air pressure, gravity, magnetic north, drag), `sublevel` API (pose, velocity, mass, inertia, UUID, name) | https://github.com/TechTastic/CC-Sable |
| CC:C Bridge | `create_source` (terminal-like), `RedRouter` (redstone per-side), `Animatronic` (puppet control with face/rotation), `Scroller Pane` | https://cccbridge.kleinbox.dev/ |
| CC: Direct GPU | `directgpu` peripheral (130+ functions: display management, 2D drawing, text, JPEG, 3D camera/primitives/models/lighting, textures, input events, world data, controllers, vector graphics, metaballs, calibration), `map_reader` peripheral | https://github.com/tiktop101/CC-DirectGPU-Mod |
| Basalt 2 | UI framework: frames, buttons, labels, inputs, lists. Not a peripheral — a Lua library. | https://basalt.madefor.cc/ |

CC: Direct GPU is currently 1.20.1 only; a friend is porting it to 1.21.1.

## Repository Structure

```
FriendsCC/
├── CLAUDE.md                        # Root: CC:T runtime rules, Lua 5.1 constraints,
│                                    #   coding conventions, @-references to type stubs
├── .luarc.json                      # LuaLS config — workspace.library points to types/
├── lib/                             # Shared Lua modules (deployed to computers)
│   ├── net.lua                      # Rednet: typed protocols, RPC, discovery, serve
│   ├── event.lua                    # Event loop / listener (for non-Basalt projects)
│   └── log.lua                      # Structured logging to file or monitor
├── types/                           # LuaLS EmmyLua stubs (NOT deployed — dev-only)
│   ├── cc-tweaked/
│   │   ├── turtle.lua
│   │   ├── redstone.lua
│   │   ├── rednet.lua
│   │   ├── peripheral.lua
│   │   ├── fs.lua
│   │   ├── http.lua
│   │   ├── os.lua
│   │   ├── term.lua
│   │   ├── window.lua
│   │   ├── textutils.lua
│   │   ├── colors.lua
│   │   ├── settings.lua
│   │   ├── shell.lua
│   │   ├── multishell.lua
│   │   ├── gps.lua
│   │   ├── paintutils.lua
│   │   ├── parallel.lua
│   │   ├── keys.lua
│   │   ├── disk.lua
│   │   ├── pocket.lua
│   │   ├── io.lua
│   │   ├── vector.lua
│   │   └── peripherals/
│   │       ├── monitor.lua
│   │       ├── modem.lua
│   │       ├── speaker.lua
│   │       └── printer.lua
│   ├── cc-sable/
│   │   ├── aero.lua
│   │   └── sublevel.lua
│   ├── ccc-bridge/
│   │   ├── source.lua
│   │   ├── red-router.lua
│   │   ├── animatronic.lua
│   │   └── scroller-pane.lua
│   ├── direct-gpu/
│   │   ├── gpu.lua                  # All 130+ DirectGPU functions
│   │   └── map-reader.lua
│   └── basalt/
│       └── basalt.lua               # Extracted from Basalt 2 repo (auto-generates LuaLS annotations)
├── projects/                        # Individual projects
│   └── example/
│       ├── CLAUDE.md                # Project-specific addon scope + description
│       ├── startup.lua              # Sets package.path, runs main
│       ├── main.lua                 # Entry point
│       └── install.lua              # One-liner in-game installer
├── scripts/
│   ├── new-project.sh               # Interactive scaffolding tool
│   ├── config.sh                    # GitHub username/repo config
│   └── templates/
│       ├── CLAUDE.md.template       # Project CLAUDE.md template
│       ├── startup.lua.template
│       ├── main.lua.template
│       ├── install.lua.template
│       └── deploy.sh.template
└── .gitignore
```

## CLAUDE.md Chain

### Root CLAUDE.md

Loaded in every conversation opened from the repo root or any subdirectory. Contains:

1. **Runtime environment** — CC:Tweaked runs Lua 5.1. No bitwise operators (`bit32` instead), no integers (all doubles), no `goto`, no `utf8` lib. `string` library is standard Lua 5.1. `table.unpack` does not exist, use `unpack`.
2. **CC:Tweaked behavioral rules**:
   - Most peripheral/turtle/rednet calls can fail and return `nil, error`. Always check return values.
   - `os.pullEvent()` yields the coroutine. Never busy-wait; use events/timers.
   - `rednet.receive()` blocks until message or timeout.
   - `http.get()` / `http.post()` can return nil on failure.
   - `sleep(n)` is an alias for `os.sleep(n)`.
   - `peripheral.wrap()` returns nil if nothing is attached.
   - `turtle.inspect()` returns `boolean, table` — check the boolean first.
   - Colors are powers of 2 (bitmask), not sequential. Use `colors.white`, `colors.orange`, etc.
   - `fs.open()` returns a handle or nil. Mode strings: `"r"`, `"w"`, `"a"`, `"rb"`, `"wb"`, `"ab"`.
   - `textutils.serializeJSON()` / `textutils.unserializeJSON()` for JSON, not a `json` library.
   - Computers have limited storage (default ~1MB). Keep files small.
   - `require()` is CC:T's implementation, not standard Lua. Respects `package.path`.
3. **Coding conventions**:
   - Use `local` for all variables and functions.
   - Prefer `require()` over `os.loadAPI()`.
   - Use `cc.expect` (`local expect = require("cc.expect").expect`) for argument validation in library code.
   - Shared libs live in `lib/`, projects extend `package.path` in `startup.lua`.
   - For UI, use Basalt 2 (`require("basalt")`).
   - Always end Basalt programs with `basalt.run()`.
4. **Type stub references** — `@`-references to all `types/cc-tweaked/` stubs (always loaded).
5. **Addon index** — short list of available addon stubs:
   - CC:Sable (`types/cc-sable/`): Aerodynamics + Sub-Level physics for Create: Aeronautics
   - CC:C Bridge (`types/ccc-bridge/`): Create display/redstone/animatronic peripherals
   - CC: Direct GPU (`types/direct-gpu/`): Full RGB graphics, 3D, controllers, JPEG
   - Basalt 2 (`types/basalt/`): UI framework
6. **Deploy convention** — programs deployed via HTTP/wget. Entrypoint is `startup.lua` which sets `package.path` and runs `main.lua`.

### Project CLAUDE.md

Per-project, thin. Generated by scaffolding. Contains:

1. **Project name and description** — one paragraph.
2. **Addon `@`-references** — only the type stubs this project uses. This scopes Claude's knowledge so it doesn't hallucinate APIs from mods the project doesn't use.
3. **Lib `@`-references** — which shared libs from `lib/` are used.
4. **Project-specific notes** — hardware layout, computer IDs, network protocols, any context Claude needs.

Example:
```markdown
# Airship Autopilot

PID-controlled airship autopilot using CC:Sable sublevel API.
Reads physics state, computes corrections, outputs to redstone.

## Addons
@types/cc-sable/aero.lua
@types/cc-sable/sublevel.lua
@types/basalt/basalt.lua

## Libs
@lib/net.lua
@lib/log.lua

## Hardware
- Advanced Computer inside the airship contraption
- Wireless modem on top (for GPS + remote commands)
- The sublevel API is available because the computer is on the contraption
```

## Type Stubs

All stubs are pure EmmyLua annotation files. Design rules:

- Every file starts with `---@meta` (tells LuaLS this is a definition, not runtime code).
- Global APIs (`turtle`, `rednet`, `aero`, `sublevel`) declared as globals.
- Peripheral types use `---@class` so `peripheral.wrap()` / `peripheral.find()` return typed objects.
- Every function documents what errors/failures it can produce.
- Return types use Lua table shapes where the API returns tables (e.g. `{position: vector, orientation: quaternion}`), not just `table`.
- Functions that yield are marked with `---Yields.`
- For DirectGPU (130+ functions), organized into sections with region comments matching the README categories.
- For Basalt 2, extract the auto-generated LuaLS annotations from the Basalt2 GitHub repo (`Pyroxenium/Basalt2`). If the annotations aren't directly available as a standalone file, generate stubs from the documentation covering frames, buttons, labels, inputs, lists, and their common methods.

Example stub (`types/cc-sable/sublevel.lua`):
```lua
---@meta

---Sub-Level API for Create: Aeronautics contraptions.
---Only available on computers physically on a Sub-Level.
---Added by CC:Sable.
---@class sublevelAPI
sublevel = {}

---Check if this computer is on a Sub-Level.
---@return boolean onSubLevel true if on a Sub-Level
function sublevel.isInPlotGrid() end

---@return string uuid The Sub-Level's UUID
---@nodiscard
---Errors if computer is not on a Sub-Level.
function sublevel.getUniqueId() end

---@return string name The Sub-Level's name
---Errors if computer is not on a Sub-Level.
function sublevel.getName() end

---@param newName string
---Errors if computer is not on a Sub-Level.
function sublevel.setName(newName) end

---@return {position: vector, orientation: quaternion, scale: vector, rotationPoint: vector}
---Errors if computer is not on a Sub-Level.
function sublevel.getLogicalPose() end

---@return {position: vector, orientation: quaternion, scale: vector, rotationPoint: vector}
---Errors if computer is not on a Sub-Level.
function sublevel.getLastPose() end

---@return vector velocity Global velocity
function sublevel.getVelocity() end

---@return vector linearVelocity
---Errors if computer is not on a Sub-Level.
function sublevel.getLinearVelocity() end

---@return vector angularVelocity
---Errors if computer is not on a Sub-Level.
function sublevel.getAngularVelocity() end

---@return vector centerOfMass
---Errors if computer is not on a Sub-Level.
function sublevel.getCenterOfMass() end

---@return number mass
---Errors if computer is not on a Sub-Level.
function sublevel.getMass() end

---@return number inverseMass
---Errors if computer is not on a Sub-Level.
function sublevel.getInverseMass() end

---@return table inertiaTensor 3x3 matrix
---Errors if computer is not on a Sub-Level.
function sublevel.getInertiaTensor() end

---@return table inverseInertiaTensor 3x3 matrix
---Errors if computer is not on a Sub-Level.
function sublevel.getInverseInertiaTensor() end
```

## Shared Libraries

### lib/net.lua

Typed rednet protocol helpers:

- `net.open(side?)` — opens modem, auto-detects side if omitted
- `net.send(recipient, protocol, data)` — wraps `rednet.send` with protocol
- `net.receive(protocol, timeout?)` — filtered receive, returns sender + parsed data
- `net.broadcast(protocol, data)` — broadcast with protocol
- `net.rpc(recipient, method, args, timeout?)` — request/response pattern, returns result or nil+error
- `net.serve(protocol, handlers)` — event loop dispatching messages to handler functions by method name

### lib/event.lua

Event loop for non-Basalt projects:

- `event.on(eventName, callback)` — register event handler
- `event.every(seconds, callback)` — recurring timer
- `event.run()` — main loop (pulls events, dispatches to handlers)
- `event.stop()` — break the loop

### lib/log.lua

Structured logging:

- `log.init(path?)` — open log file (default `/log.txt`)
- `log.info(msg, ...)`, `log.warn(msg, ...)`, `log.error(msg, ...)`
- `log.toMonitor(side)` — mirror log output to attached monitor
- Timestamps via `os.epoch("utc")`

## Scaffolding Tool

`scripts/new-project.sh` — interactive Bash script run on host machine.

Prompts for:
1. Project name (kebab-case, becomes directory name)
2. One-line description
3. Addon selection (toggle: CC:Sable, CC:C Bridge, CC: Direct GPU, Basalt)
4. Shared lib selection (toggle: net, event, log)

Generates under `projects/<name>/`:
- `CLAUDE.md` — from template, with selected addon `@`-references and lib references
- `startup.lua` — sets `package.path` for selected libs, runs `main.lua`
- `main.lua` — skeleton with `require()` calls for selected libs + Basalt if chosen
- `install.lua` — in-game one-liner installer
- `deploy.sh` — outputs wget commands for manual install

Templates live in `scripts/templates/`. GitHub username/repo configured in `scripts/config.sh`.

## Deploy Strategy

### Method 1: deploy.sh (per-project)

Generated by scaffolding. Outputs wget commands to paste into CC:Tweaked shell:

```bash
#!/bin/bash
source "$(dirname "$0")/../../scripts/config.sh"
echo "-- Run in CC:Tweaked computer:"
echo "wget $REPO_RAW/lib/net.lua /lib/net.lua"
echo "wget $REPO_RAW/lib/log.lua /lib/log.lua"
echo "wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -r"
echo "wget $REPO_RAW/projects/<name>/startup.lua /startup.lua"
echo "wget $REPO_RAW/projects/<name>/main.lua /main.lua"
```

### Method 2: install.lua (per-project)

One-liner in-game:
```
wget run https://raw.githubusercontent.com/<user>/FriendsCC/main/projects/<name>/install.lua
```

The installer creates directories, downloads libs, installs Basalt if needed, and downloads project files. Reboot to start.

### Configuration

`scripts/config.sh`:
```bash
GITHUB_USER="<your-username>"
GITHUB_REPO="FriendsCC"
GITHUB_BRANCH="main"
REPO_RAW="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH"
```

## LuaLS Configuration

`.luarc.json`:
```json
{
  "runtime": {
    "version": "Lua 5.1"
  },
  "workspace": {
    "library": [
      "types/cc-tweaked",
      "types/cc-sable",
      "types/ccc-bridge",
      "types/direct-gpu",
      "types/basalt"
    ]
  },
  "diagnostics": {
    "globals": [
      "turtle", "redstone", "rs", "rednet", "peripheral", "fs", "http",
      "os", "term", "window", "textutils", "colors", "colours",
      "settings", "shell", "multishell", "gps", "paintutils", "parallel",
      "keys", "disk", "pocket", "io", "vector", "sleep", "write", "print",
      "read", "printError",
      "aero", "aerodynamics", "sublevel",
      "bit32", "unpack"
    ]
  }
}
```
