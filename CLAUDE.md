# FriendsCC — CC:Tweaked 1.21.1 Monorepo

Personal monorepo for CC:Tweaked Lua development. Contains shared libraries, type stubs, and project scaffolding.

## Runtime Environment

CC:Tweaked runs **Lua 5.1**. Key constraints:
- No bitwise operators — use `bit32` library instead
- No integers — all numbers are IEEE 754 doubles
- No `goto` statement
- No `utf8` library
- `table.unpack` does not exist — use `unpack`
- `string` library is standard Lua 5.1
- `require()` is CC:T's own implementation, not standard Lua. It respects `package.path`.

## CC:Tweaked Behavioral Rules

- Most peripheral/turtle/rednet calls can fail and return `nil, error`. Always check return values.
- `os.pullEvent()` yields the coroutine. Never busy-wait; use events and timers.
- `rednet.receive()` blocks until a message arrives or timeout expires.
- `http.get()` and `http.post()` can return nil on failure.
- `sleep(n)` is an alias for `os.sleep(n)`.
- `peripheral.wrap()` returns nil if nothing is attached on that side/name.
- `peripheral.find()` returns nil if no peripheral of that type exists.
- `turtle.inspect()` returns `boolean, table` — check the boolean first.
- Colors are powers of 2 (bitmask), not sequential. Use `colors.white`, `colors.orange`, etc.
- `fs.open()` returns a handle or nil. Mode strings: `"r"`, `"w"`, `"a"`, `"rb"`, `"wb"`, `"ab"`.
- `textutils.serializeJSON()` / `textutils.unserializeJSON()` for JSON — there is no `json` library.
- Computers have limited storage (default ~1MB). Keep files small.
- `rednet.open()` requires a modem side string. Use `peripheral.find("modem")` to auto-detect.
- `os.epoch("utc")` returns milliseconds since Unix epoch. `os.clock()` returns CPU time in seconds.
- Events are pulled with `os.pullEvent(filter?)` — the filter is an event name string, not a function.
- `parallel.waitForAll()` and `parallel.waitForAny()` take functions, not coroutines.

## Coding Conventions

- Use `local` for all variables and functions.
- Prefer `require()` over the deprecated `os.loadAPI()`.
- Use `cc.expect` for argument validation in library code: `local expect = require("cc.expect").expect`
- Shared libs live in `lib/`. Load them with `dofile("/lib/foo.lua")`, NOT `require` — CC:T's `require` doesn't reliably find custom paths.
- For UI, use Basalt 2 (`local basalt = require("basalt")`). Always end Basalt programs with `basalt.run()`.
- Basalt 2 API: use `getVisible` not `isVisible`, `getText`/`setText` not `getValue`/`setValue`, `setPlaceholder` not `setDefaultText`. Use `basalt.schedule(fn)` for background tasks — `autoUpdate` does not exist. Always check `types/basalt/basalt.lua` for correct method names.
- Programs are deployed via HTTP/wget. Entrypoint is always `startup.lua` which sets `package.path` and runs `main.lua`.

## Type Stubs (always loaded)

@types/cc-tweaked/turtle.lua
@types/cc-tweaked/redstone.lua
@types/cc-tweaked/rednet.lua
@types/cc-tweaked/peripheral.lua
@types/cc-tweaked/fs.lua
@types/cc-tweaked/http.lua
@types/cc-tweaked/os.lua
@types/cc-tweaked/term.lua
@types/cc-tweaked/window.lua
@types/cc-tweaked/textutils.lua
@types/cc-tweaked/colors.lua
@types/cc-tweaked/settings.lua
@types/cc-tweaked/shell.lua
@types/cc-tweaked/multishell.lua
@types/cc-tweaked/gps.lua
@types/cc-tweaked/paintutils.lua
@types/cc-tweaked/parallel.lua
@types/cc-tweaked/keys.lua
@types/cc-tweaked/disk.lua
@types/cc-tweaked/pocket.lua
@types/cc-tweaked/io.lua
@types/cc-tweaked/vector.lua
@types/cc-tweaked/peripherals/monitor.lua
@types/cc-tweaked/peripherals/modem.lua
@types/cc-tweaked/peripherals/speaker.lua
@types/cc-tweaked/peripherals/printer.lua

## Available Addon Stubs

These are NOT loaded by default. Projects reference them in their own CLAUDE.md.

- **CC:Sable** (`types/cc-sable/`): `aero` (aerodynamics) + `sublevel` (physics control) APIs for Create: Aeronautics contraptions
- **CC:C Bridge** (`types/ccc-bridge/`): `create_source`, `RedRouter`, `Animatronic`, `Scroller Pane` peripherals for Create integration
- **CC: Direct GPU** (`types/direct-gpu/`): `directgpu` peripheral with 130+ functions for full RGB 2D/3D graphics, JPEG, controllers, world data; `map_reader` peripheral
- **Basalt 2** (`types/basalt/`): UI framework — frames, buttons, labels, inputs, lists, checkboxes, dropdowns, and more
