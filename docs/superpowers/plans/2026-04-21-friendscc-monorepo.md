# FriendsCC Monorepo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a CC:Tweaked 1.21.1 monorepo with CLAUDE.md chain, LuaLS type stubs, shared libraries, and project scaffolding that enables Claude to write correct Lua code for CC:Tweaked and addons.

**Architecture:** CLAUDE.md chain (root + per-project) provides behavioral guidance. EmmyLua type stubs in `types/` give Claude and LuaLS complete API signatures. Shared libs in `lib/` avoid boilerplate. A shell scaffolding tool generates new projects with correct `@`-references.

**Tech Stack:** Lua 5.1 (CC:Tweaked runtime), EmmyLua annotations (LuaLS), Bash (scaffolding/deploy scripts)

**Spec:** `docs/superpowers/specs/2026-04-21-friendscc-monorepo-design.md`

**Note on testing:** This project has no automated test suite — it's Lua for CC:Tweaked (runs inside Minecraft). Validation is: LuaLS parses stubs without errors, shell scripts run without errors, generated files match expected structure. Each task ends with a verification step.

---

## Task 1: Repository Foundation

**Files:**
- Create: `.gitignore`
- Create: `.luarc.json`
- Create: `CLAUDE.md`

- [ ] **Step 1: Initialize git repo**

```bash
cd /home/marlon/Code/Lua/FriendsCC
git init
```

- [ ] **Step 2: Create .gitignore**

Create `.gitignore`:

```
# OS
.DS_Store
Thumbs.db

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# LuaLS
.luarc.json.bak
log/

# Build artifacts
*.out
```

- [ ] **Step 3: Create .luarc.json**

Create `.luarc.json`:

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

- [ ] **Step 4: Create root CLAUDE.md**

Create `CLAUDE.md`:

```markdown
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
- Shared libs live in `lib/`. Projects extend `package.path` in their `startup.lua`.
- For UI, use Basalt 2 (`local basalt = require("basalt")`). Always end Basalt programs with `basalt.run()`.
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
```

- [ ] **Step 5: Commit foundation**

```bash
git add .gitignore .luarc.json CLAUDE.md
git commit -m "feat: repository foundation with CLAUDE.md, LuaLS config, gitignore"
```

---

## Task 2: CC:Tweaked Core Type Stubs — System APIs

**Files:**
- Create: `types/cc-tweaked/os.lua`
- Create: `types/cc-tweaked/fs.lua`
- Create: `types/cc-tweaked/term.lua`
- Create: `types/cc-tweaked/window.lua`
- Create: `types/cc-tweaked/io.lua`

These are the fundamental system APIs that everything else depends on.

- [ ] **Step 1: Create types/cc-tweaked/os.lua**

```lua
---@meta

---The os API provides functions for interacting with the computer's OS.
---@class osAPI
os = {}

---Pause execution for the specified number of seconds.
---Yields.
---@param time number The number of seconds to sleep for
function os.sleep(time) end

---Get the current CraftOS version string.
---@return string version e.g. "CraftOS 1.9"
---@nodiscard
function os.version() end

---Get this computer's ID.
---@return number id The computer's unique ID
---@nodiscard
function os.getComputerID() end

---@return number id The computer's unique ID
---@nodiscard
function os.computerID() end

---Get this computer's label.
---@return string|nil label The computer's label, or nil if not set
---@nodiscard
function os.getComputerLabel() end

---@return string|nil label The computer's label, or nil if not set
---@nodiscard
function os.computerLabel() end

---Set this computer's label.
---@param label? string The new label, or nil to clear
function os.setComputerLabel(label) end

---Run the program at the given path with the given arguments.
---@param env table The environment to run the program in
---@param path string The path to the program
---@param ... string Arguments to pass to the program
---@return boolean success Whether the program ran successfully
function os.run(env, path, ...) end

---Adds an event to the event queue with the given name and parameters.
---@param name string The event name
---@param ... any Additional parameters
function os.queueEvent(name, ...) end

---Pulls an event from the event queue, yielding until one is available.
---Yields. Throws on "terminate" events.
---@param filter? string Only pull events with this name
---@return string event The event name
---@return any ... Additional event parameters
function os.pullEvent(filter) end

---Like os.pullEvent(), but does not throw on "terminate" events.
---Yields.
---@param filter? string Only pull events with this name
---@return string event The event name
---@return any ... Additional event parameters
function os.pullEventRaw(filter) end

---Start a timer that fires a "timer" event after the given delay.
---@param delay number The delay in seconds
---@return number timerID The timer's ID
function os.startTimer(delay) end

---Cancel a running timer.
---@param timerID number The timer ID from os.startTimer()
function os.cancelTimer(timerID) end

---Set an alarm that fires an "alarm" event at the given in-game time.
---@param time number The in-game time (0.0 to 24.0)
---@return number alarmID The alarm's ID
function os.setAlarm(time) end

---Cancel a running alarm.
---@param alarmID number The alarm ID from os.setAlarm()
function os.cancelAlarm(alarmID) end

---Get the current CPU time in seconds.
---@return number time CPU time in seconds
---@nodiscard
function os.clock() end

---Get the current in-game time.
---@param locale? string "ingame" (default), "utc", or "local"
---@return number time The current time
---@nodiscard
function os.time(locale) end

---Get the current in-game day.
---@param locale? string "ingame" (default), "utc", or "local"
---@return number day The current day
---@nodiscard
function os.day(locale) end

---Get the current time as milliseconds since epoch.
---@param locale? string "ingame" (default), "utc", or "local"
---@return number epoch Milliseconds since epoch
---@nodiscard
function os.epoch(locale) end

---Format a time/date string.
---@param format? string The format string (strftime-style), or "*t" for a table
---@param time? number The time to format (from os.epoch)
---@return string|table result The formatted string or table
---@nodiscard
function os.date(format, time) end

---Shutdown the computer.
function os.shutdown() end

---Reboot the computer.
function os.reboot() end

---An alias for os.sleep().
---Yields.
---@param time number The number of seconds to sleep for
function sleep(time) end
```

- [ ] **Step 2: Create types/cc-tweaked/fs.lua**

```lua
---@meta

---The fs API provides functions for interacting with the filesystem.
---@class fsAPI
fs = {}

---List files and directories in a path.
---@param path string The directory to list
---@return string[] files List of file/directory names
---@nodiscard
function fs.list(path) end

---Find files matching a wildcard pattern.
---@param pattern string The wildcard pattern (e.g. "rom/*/command*")
---@return string[] files Matching file paths
---@nodiscard
function fs.find(pattern) end

---Check if a path exists.
---@param path string The path to check
---@return boolean exists
---@nodiscard
function fs.exists(path) end

---Check if a path is a directory.
---@param path string The path to check
---@return boolean isDir
---@nodiscard
function fs.isDir(path) end

---Check if a path is read-only.
---@param path string The path to check
---@return boolean isReadOnly
---@nodiscard
function fs.isReadOnly(path) end

---Get the filename portion of a path.
---@param path string The path
---@return string name The filename
---@nodiscard
function fs.getName(path) end

---Get the directory portion of a path.
---@param path string The path
---@return string dir The parent directory
---@nodiscard
function fs.getDir(path) end

---Get the size of a file in bytes.
---@param path string The path to the file
---@return number size Size in bytes
---@nodiscard
function fs.getSize(path) end

---Get the free space on the drive containing a path.
---@param path string The path
---@return number|"unlimited" freeSpace Free space in bytes
---@nodiscard
function fs.getFreeSpace(path) end

---Get the name of the drive containing a path.
---@param path string The path
---@return string|nil drive The drive name
---@nodiscard
function fs.getDrive(path) end

---Get the capacity of the drive containing a path.
---@param path string The path
---@return number|nil capacity Capacity in bytes
---@nodiscard
function fs.getCapacity(path) end

---Create a directory (and parents).
---@param path string The directory to create
function fs.makeDir(path) end

---Move a file or directory.
---@param from string The source path
---@param to string The destination path
function fs.move(from, to) end

---Copy a file or directory.
---@param from string The source path
---@param to string The destination path
function fs.copy(from, to) end

---Delete a file or directory.
---@param path string The path to delete
function fs.delete(path) end

---Combine path components.
---@param base string The base path
---@param ... string Additional path components
---@return string combined The combined path
---@nodiscard
function fs.combine(base, ...) end

---@class ReadHandle
---@field readLine fun(self: ReadHandle, withTrailing?: boolean): string|nil
---@field readAll fun(self: ReadHandle): string|nil
---@field read fun(self: ReadHandle, count?: number): string|nil
---@field close fun(self: ReadHandle)

---@class WriteHandle
---@field write fun(self: WriteHandle, text: string)
---@field writeLine fun(self: WriteHandle, text: string)
---@field flush fun(self: WriteHandle)
---@field close fun(self: WriteHandle)

---@class BinaryReadHandle
---@field read fun(self: BinaryReadHandle, count?: number): number|string|nil
---@field readAll fun(self: BinaryReadHandle): string|nil
---@field readLine fun(self: BinaryReadHandle, withTrailing?: boolean): string|nil
---@field close fun(self: BinaryReadHandle)
---@field seek fun(self: BinaryReadHandle, whence?: string, offset?: number): number

---@class BinaryWriteHandle
---@field write fun(self: BinaryWriteHandle, value: number|string)
---@field flush fun(self: BinaryWriteHandle)
---@field close fun(self: BinaryWriteHandle)
---@field seek fun(self: BinaryWriteHandle, whence?: string, offset?: number): number

---Open a file for reading or writing.
---@param path string The file path
---@param mode string The mode: "r", "w", "a", "rb", "wb", "ab"
---@return ReadHandle|WriteHandle|BinaryReadHandle|BinaryWriteHandle|nil handle The file handle, or nil on failure
---@return string|nil error Error message if handle is nil
function fs.open(path, mode) end

---Complete a partial file/directory name.
---@param partial string The partial name to complete
---@param path string The directory to complete in
---@param includeFiles? boolean Include files (default true)
---@param includeDirs? boolean Include directories (default true)
---@return string[] completions List of completions
---@nodiscard
function fs.complete(partial, path, includeFiles, includeDirs) end

---Get attributes of a file.
---@param path string The file path
---@return {size: number, isDir: boolean, isReadOnly: boolean, created: number, modified: number} attributes
---@nodiscard
function fs.attributes(path) end

---Check if a path is the root of a drive.
---@param path string The path to check
---@return boolean isDriveRoot
---@nodiscard
function fs.isDriveRoot(path) end
```

- [ ] **Step 3: Create types/cc-tweaked/term.lua**

```lua
---@meta

---The terminal API for drawing text and controlling the cursor.
---@class termAPI
term = {}

---Write text at the current cursor position.
---@param text string The text to write
function term.write(text) end

---Write text using blittle-style color strings.
---@param text string The text to write
---@param textColors string Hex color string for text (same length as text)
---@param bgColors string Hex color string for background (same length as text)
function term.blit(text, textColors, bgColors) end

---Clear the entire terminal.
function term.clear() end

---Clear the current line.
function term.clearLine() end

---Get the cursor position.
---@return number x The x position (1-based)
---@return number y The y position (1-based)
---@nodiscard
function term.getCursorPos() end

---Set the cursor position.
---@param x number The x position (1-based)
---@param y number The y position (1-based)
function term.setCursorPos(x, y) end

---Get whether the cursor is blinking.
---@return boolean blink
---@nodiscard
function term.getCursorBlink() end

---Set whether the cursor blinks.
---@param blink boolean
function term.setCursorBlink(blink) end

---Get the terminal size.
---@return number width
---@return number height
---@nodiscard
function term.getSize() end

---Scroll the terminal contents.
---@param n number Lines to scroll (positive = up)
function term.scroll(n) end

---Check if the terminal supports color.
---@return boolean isColor
---@nodiscard
function term.isColor() end

---Check if the terminal supports color (British spelling).
---@return boolean isColour
---@nodiscard
function term.isColour() end

---Get the current text color.
---@return number color A colors.* value
---@nodiscard
function term.getTextColor() end

---@return number colour A colours.* value
---@nodiscard
function term.getTextColour() end

---Set the text color.
---@param color number A colors.* value
function term.setTextColor(color) end

---@param colour number A colours.* value
function term.setTextColour(colour) end

---Get the current background color.
---@return number color A colors.* value
---@nodiscard
function term.getBackgroundColor() end

---@return number colour A colours.* value
---@nodiscard
function term.getBackgroundColour() end

---Set the background color.
---@param color number A colors.* value
function term.setBackgroundColor(color) end

---@param colour number A colours.* value
function term.setBackgroundColour(colour) end

---Get the RGB values of a palette color.
---@param color number A colors.* value
---@return number r Red (0-1)
---@return number g Green (0-1)
---@return number b Blue (0-1)
---@nodiscard
function term.getPaletteColor(color) end

---@param colour number A colours.* value
---@return number r Red (0-1)
---@return number g Green (0-1)
---@return number b Blue (0-1)
---@nodiscard
function term.getPaletteColour(colour) end

---Set a palette color from RGB or hex.
---@param color number A colors.* value
---@param r number Red (0-1) or hex color (0x000000-0xFFFFFF)
---@param g? number Green (0-1)
---@param b? number Blue (0-1)
function term.setPaletteColor(color, r, g, b) end

---@param colour number A colours.* value
---@param r number Red (0-1) or hex color
---@param g? number Green (0-1)
---@param b? number Blue (0-1)
function term.setPaletteColour(colour, r, g, b) end

---Redirect terminal output to another terminal object.
---@param target table The terminal object to redirect to
---@return table previous The previous terminal object
function term.redirect(target) end

---Get the current terminal object.
---@return table current The current terminal object
---@nodiscard
function term.current() end

---Get the native (original) terminal object.
---@return table native The native terminal object
---@nodiscard
function term.native() end

---Write text to the terminal, advancing the cursor.
---Global function, not part of term API.
---@param text any The value to write (converted to string)
function write(text) end

---Read a line of text from the terminal.
---Yields.
---@param replaceChar? string Character to display instead of typed chars (for passwords)
---@param history? string[] Previous entries for up/down arrow history
---@param completeFn? fun(partial: string): string[] Tab-completion function
---@param default? string Default text to pre-fill
---@return string|nil text The entered text, or nil if terminated
function read(replaceChar, history, completeFn, default) end

---Print an error message in red.
---@param ... any The values to print
function printError(...) end
```

- [ ] **Step 4: Create types/cc-tweaked/window.lua**

```lua
---@meta

---The window API for creating terminal window objects.
---@class windowAPI
window = {}

---@class Window
---@field write fun(self: Window, text: string)
---@field blit fun(self: Window, text: string, textColors: string, bgColors: string)
---@field clear fun(self: Window)
---@field clearLine fun(self: Window)
---@field getCursorPos fun(self: Window): number, number
---@field setCursorPos fun(self: Window, x: number, y: number)
---@field getCursorBlink fun(self: Window): boolean
---@field setCursorBlink fun(self: Window, blink: boolean)
---@field getSize fun(self: Window): number, number
---@field scroll fun(self: Window, n: number)
---@field isColor fun(self: Window): boolean
---@field isColour fun(self: Window): boolean
---@field getTextColor fun(self: Window): number
---@field getTextColour fun(self: Window): number
---@field setTextColor fun(self: Window, color: number)
---@field setTextColour fun(self: Window, colour: number)
---@field getBackgroundColor fun(self: Window): number
---@field getBackgroundColour fun(self: Window): number
---@field setBackgroundColor fun(self: Window, color: number)
---@field setBackgroundColour fun(self: Window, colour: number)
---@field getPaletteColor fun(self: Window, color: number): number, number, number
---@field getPaletteColour fun(self: Window, colour: number): number, number, number
---@field setPaletteColor fun(self: Window, color: number, r: number, g?: number, b?: number)
---@field setPaletteColour fun(self: Window, colour: number, r: number, g?: number, b?: number)
---@field setVisible fun(self: Window, visible: boolean)
---@field isVisible fun(self: Window): boolean
---@field getPosition fun(self: Window): number, number
---@field reposition fun(self: Window, x: number, y: number, width?: number, height?: number, parent?: table)
---@field getLine fun(self: Window, y: number): string, string, string
---@field redraw fun(self: Window)

---Create a new window.
---@param parent table The parent terminal object
---@param x number X position in the parent (1-based)
---@param y number Y position in the parent (1-based)
---@param width number Width of the window
---@param height number Height of the window
---@param visible? boolean Whether the window is initially visible (default true)
---@return Window window The new window object
function window.create(parent, x, y, width, height, visible) end
```

- [ ] **Step 5: Create types/cc-tweaked/io.lua**

```lua
---@meta

---Limited standard Lua io library as implemented by CC:Tweaked.
---@class ioAPI
io = {}

---Open a file.
---@param path string The file path
---@param mode? string The mode (default "r")
---@return file*|nil handle The file handle
---@return string|nil error Error message
function io.open(path, mode) end

---Close a file handle.
---@param file? file* The handle to close (default: current output)
function io.close(file) end

---Read from the current input.
---@param ... string|number Format strings
---@return string|number|nil ...
function io.read(...) end

---Write to the current output.
---@param ... string|number Values to write
function io.write(...) end

---Iterate over lines from a file.
---@param path? string The file path (or current input if nil)
---@param ... string|number Format strings
---@return fun(): string|nil iterator
function io.lines(path, ...) end

---Set or get the current input file.
---@param file? string|file* A path or handle
---@return file* handle The current input handle
function io.input(file) end

---Set or get the current output file.
---@param file? string|file* A path or handle
---@return file* handle The current output handle
function io.output(file) end
```

- [ ] **Step 6: Verify stubs parse**

```bash
ls -la types/cc-tweaked/os.lua types/cc-tweaked/fs.lua types/cc-tweaked/term.lua types/cc-tweaked/window.lua types/cc-tweaked/io.lua
```

Expected: all 5 files exist with non-zero size.

- [ ] **Step 7: Commit**

```bash
git add types/cc-tweaked/os.lua types/cc-tweaked/fs.lua types/cc-tweaked/term.lua types/cc-tweaked/window.lua types/cc-tweaked/io.lua
git commit -m "feat: CC:Tweaked type stubs — system APIs (os, fs, term, window, io)"
```

---

## Task 3: CC:Tweaked Core Type Stubs — Networking & Peripherals

**Files:**
- Create: `types/cc-tweaked/rednet.lua`
- Create: `types/cc-tweaked/peripheral.lua`
- Create: `types/cc-tweaked/gps.lua`
- Create: `types/cc-tweaked/peripherals/monitor.lua`
- Create: `types/cc-tweaked/peripherals/modem.lua`
- Create: `types/cc-tweaked/peripherals/speaker.lua`
- Create: `types/cc-tweaked/peripherals/printer.lua`
- Create: `types/cc-tweaked/disk.lua`

- [ ] **Step 1: Create types/cc-tweaked/rednet.lua**

```lua
---@meta

---The rednet API provides a higher-level networking protocol over modems.
---@class rednetAPI
rednet = {}

---Open a modem for rednet use.
---@param modem string The side or network name of the modem
function rednet.open(modem) end

---Close a modem (or all modems).
---@param modem? string The modem to close, or nil to close all
function rednet.close(modem) end

---Check if a modem is open.
---@param modem? string The modem to check, or nil to check any
---@return boolean isOpen
---@nodiscard
function rednet.isOpen(modem) end

---Send a message to a specific computer.
---@param recipient number The target computer ID
---@param message any The message to send (will be serialized)
---@param protocol? string The protocol name
---@return boolean success Whether the message was sent
function rednet.send(recipient, message, protocol) end

---Broadcast a message to all computers.
---@param message any The message to broadcast
---@param protocol? string The protocol name
function rednet.broadcast(message, protocol) end

---Wait for a rednet message.
---Yields.
---@param protocolFilter? string Only receive messages with this protocol
---@param timeout? number Timeout in seconds
---@return number|nil senderID The sender's computer ID, or nil on timeout
---@return any message The message received
---@return string|nil protocol The protocol used
function rednet.receive(protocolFilter, timeout) end

---Register this computer as a host for a protocol.
---@param protocol string The protocol name
---@param hostname string The hostname to register
function rednet.host(protocol, hostname) end

---Unregister as a host for a protocol.
---@param protocol string The protocol to unhost
function rednet.unhost(protocol) end

---Look up computers hosting a protocol.
---Yields.
---@param protocol string The protocol to look up
---@param hostname? string A specific hostname to find
---@return number|nil ... Computer ID(s), or nil if not found
function rednet.lookup(protocol, hostname) end
```

- [ ] **Step 2: Create types/cc-tweaked/peripheral.lua**

```lua
---@meta

---The peripheral API for interacting with peripheral blocks.
---@class peripheralAPI
peripheral = {}

---Get the names of all connected peripherals.
---@return string[] names List of peripheral names
---@nodiscard
function peripheral.getNames() end

---Check if a peripheral is present on a side or name.
---@param name string The side or network name
---@return boolean isPresent
---@nodiscard
function peripheral.isPresent(name) end

---Get the type(s) of a peripheral.
---@param peripheral string|table The side/name or wrapped peripheral
---@return string ... The peripheral type(s)
---@nodiscard
function peripheral.getType(peripheral) end

---Check if a peripheral has a specific type.
---@param peripheral string|table The side/name or wrapped peripheral
---@param type string The type to check for
---@return boolean|nil hasType true, false, or nil if peripheral not found
---@nodiscard
function peripheral.hasType(peripheral, type) end

---Get the methods available on a peripheral.
---@param name string The side or network name
---@return string[]|nil methods List of method names, or nil if not present
---@nodiscard
function peripheral.getMethods(name) end

---Get the name of a wrapped peripheral.
---@param peripheral table The wrapped peripheral
---@return string name The peripheral's name
---@nodiscard
function peripheral.getName(peripheral) end

---Call a method on a peripheral.
---@param name string The side or network name
---@param method string The method name
---@param ... any Arguments to the method
---@return any ... Return values from the method
function peripheral.call(name, method, ...) end

---Wrap a peripheral for direct method calls.
---@param name string The side or network name
---@return table|nil peripheral The wrapped peripheral, or nil if not present
function peripheral.wrap(name) end

---Find all peripherals of a type.
---@param type string The peripheral type to find
---@param filter? fun(name: string, wrapped: table): boolean Filter function
---@return table ... Wrapped peripherals matching the type
function peripheral.find(type, filter) end
```

- [ ] **Step 3: Create types/cc-tweaked/gps.lua**

```lua
---@meta

---The GPS API for locating computers using a GPS network.
---@class gpsAPI
gps = {}

---Locate this computer using GPS.
---Yields. Requires a wireless modem and 4+ GPS hosts.
---@param timeout? number How long to wait for responses (default 2)
---@param debug? boolean Whether to print debug info
---@return number|nil x The x coordinate, or nil if not found
---@return number|nil y The y coordinate
---@return number|nil z The z coordinate
function gps.locate(timeout, debug) end
```

- [ ] **Step 4: Create types/cc-tweaked/peripherals/monitor.lua**

```lua
---@meta

---A monitor peripheral. Exposes all term API methods plus setTextScale.
---@class Monitor
---@field write fun(self: Monitor, text: string)
---@field blit fun(self: Monitor, text: string, textColors: string, bgColors: string)
---@field clear fun(self: Monitor)
---@field clearLine fun(self: Monitor)
---@field getCursorPos fun(self: Monitor): number, number
---@field setCursorPos fun(self: Monitor, x: number, y: number)
---@field getCursorBlink fun(self: Monitor): boolean
---@field setCursorBlink fun(self: Monitor, blink: boolean)
---@field getSize fun(self: Monitor): number, number
---@field scroll fun(self: Monitor, n: number)
---@field isColor fun(self: Monitor): boolean
---@field isColour fun(self: Monitor): boolean
---@field getTextColor fun(self: Monitor): number
---@field getTextColour fun(self: Monitor): number
---@field setTextColor fun(self: Monitor, color: number)
---@field setTextColour fun(self: Monitor, colour: number)
---@field getBackgroundColor fun(self: Monitor): number
---@field getBackgroundColour fun(self: Monitor): number
---@field setBackgroundColor fun(self: Monitor, color: number)
---@field setBackgroundColour fun(self: Monitor, colour: number)
---@field getPaletteColor fun(self: Monitor, color: number): number, number, number
---@field getPaletteColour fun(self: Monitor, colour: number): number, number, number
---@field setPaletteColor fun(self: Monitor, color: number, r: number, g?: number, b?: number)
---@field setPaletteColour fun(self: Monitor, colour: number, r: number, g?: number, b?: number)
local Monitor = {}

---Set the text scale of the monitor.
---@param scale number Scale factor (0.5 to 5, in increments of 0.5)
function Monitor:setTextScale(scale) end
```

- [ ] **Step 5: Create types/cc-tweaked/peripherals/modem.lua**

```lua
---@meta

---A modem peripheral for network communication.
---@class Modem
local Modem = {}

---Open a channel for listening.
---@param channel number The channel (0-65535)
function Modem:open(channel) end

---Close a listening channel.
---@param channel number The channel to close
function Modem:close(channel) end

---Close all channels.
function Modem:closeAll() end

---Check if a channel is open.
---@param channel number The channel to check
---@return boolean isOpen
---@nodiscard
function Modem:isOpen(channel) end

---Transmit a message on a channel.
---@param channel number The channel to transmit on
---@param replyChannel number The channel to receive replies on
---@param payload any The message to send
function Modem:transmit(channel, replyChannel, payload) end

---Check if this is a wireless modem.
---@return boolean isWireless
---@nodiscard
function Modem:isWireless() end

---Get the name of the local network (wired modems only).
---@return string|nil name The network name
---@nodiscard
function Modem:getNameLocal() end

---Get the names of all peripherals on the network (wired modems only).
---@return string[] names Remote peripheral names
---@nodiscard
function Modem:getNamesRemote() end

---Check if a peripheral exists on the network (wired modems only).
---@param name string The peripheral name
---@return boolean isPresent
---@nodiscard
function Modem:isPresentRemote(name) end

---Get the type of a remote peripheral (wired modems only).
---@param name string The peripheral name
---@return string|nil type The peripheral type
---@nodiscard
function Modem:getTypeRemote(name) end

---Check if a remote peripheral has a specific type (wired modems only).
---@param name string The peripheral name
---@param type string The type to check
---@return boolean|nil hasType
---@nodiscard
function Modem:hasTypeRemote(name, type) end

---Get the methods of a remote peripheral (wired modems only).
---@param name string The peripheral name
---@return string[]|nil methods
---@nodiscard
function Modem:getMethodsRemote(name) end

---Call a method on a remote peripheral (wired modems only).
---@param remoteName string The peripheral name
---@param method string The method name
---@param ... any Arguments
---@return any ... Return values
function Modem:callRemote(remoteName, method, ...) end
```

- [ ] **Step 6: Create types/cc-tweaked/peripherals/speaker.lua**

```lua
---@meta

---A speaker peripheral for playing sounds and notes.
---@class Speaker
local Speaker = {}

---Play a noteblock-style note.
---Yields.
---@param instrument string The instrument (e.g. "harp", "bass", "bell", "flute", "chime", "guitar", "xylophone", "iron_xylophone", "cow_bell", "didgeridoo", "bit", "banjo", "pling")
---@param volume? number Volume (0.0 to 3.0, default 1.0)
---@param pitch? number Pitch (0-24, default 12)
---@return boolean success Whether the note was played
function Speaker:playNote(instrument, volume, pitch) end

---Play a Minecraft sound.
---Yields.
---@param name string The sound name (e.g. "minecraft:entity.pig.ambient")
---@param volume? number Volume (0.0 to 3.0, default 1.0)
---@param pitch? number Pitch (0.0 to 2.0, default 1.0)
---@return boolean success Whether the sound was played
function Speaker:playSound(name, volume, pitch) end

---Play PCM audio data.
---Yields.
---@param data number[] Array of 8-bit signed PCM samples (-128 to 127)
---@param volume? number Volume (0.0 to 3.0, default 1.0)
---@return boolean success Whether the audio was queued
function Speaker:playAudio(data, volume) end

---Stop all playing audio.
function Speaker:stop() end
```

- [ ] **Step 7: Create types/cc-tweaked/peripherals/printer.lua**

```lua
---@meta

---A printer peripheral.
---@class Printer
local Printer = {}

---Write text at the cursor position.
---@param text string The text to write
function Printer:write(text) end

---Set the cursor position.
---@param x number X position
---@param y number Y position
function Printer:setCursorPos(x, y) end

---Get the cursor position.
---@return number x
---@return number y
---@nodiscard
function Printer:getCursorPos() end

---Get the page size.
---@return number width
---@return number height
---@nodiscard
function Printer:getPageSize() end

---Start a new page.
---@return boolean success Whether a new page was started
function Printer:newPage() end

---Finish the current page and print it.
---@return boolean success Whether the page was printed
function Printer:endPage() end

---Set the title of the current page.
---@param title? string The page title
function Printer:setPageTitle(title) end

---Get the remaining ink level.
---@return number level Ink level
---@nodiscard
function Printer:getInkLevel() end

---Get the remaining paper level.
---@return number level Paper level
---@nodiscard
function Printer:getPaperLevel() end
```

- [ ] **Step 8: Create types/cc-tweaked/disk.lua**

```lua
---@meta

---The disk API for interacting with disk drives.
---@class diskAPI
disk = {}

---Check if a disk is present in a drive.
---@param name string The side or network name of the drive
---@return boolean isPresent
---@nodiscard
function disk.isPresent(name) end

---Get the label of the disk.
---@param name string The drive name
---@return string|nil label
---@nodiscard
function disk.getLabel(name) end

---Set the label of a disk.
---@param name string The drive name
---@param label? string The new label, or nil to clear
function disk.setLabel(name, label) end

---Check if the disk has data (is a floppy, not a music disc).
---@param name string The drive name
---@return boolean hasData
---@nodiscard
function disk.hasData(name) end

---Get the mount path of the disk.
---@param name string The drive name
---@return string|nil path The mount path (e.g. "disk")
---@nodiscard
function disk.getMountPath(name) end

---Check if the disk is a music disc.
---@param name string The drive name
---@return boolean hasAudio
---@nodiscard
function disk.hasAudio(name) end

---Get the title of a music disc.
---@param name string The drive name
---@return string|nil|false title The title, nil if not a disc, false if no title
---@nodiscard
function disk.getAudioTitle(name) end

---Play a music disc.
---@param name string The drive name
function disk.playAudio(name) end

---Stop playing a music disc.
---@param name string The drive name
function disk.stopAudio(name) end

---Eject the disk.
---@param name string The drive name
function disk.eject(name) end

---Get the unique ID of a floppy disk.
---@param name string The drive name
---@return number|nil id The disk ID
---@nodiscard
function disk.getID(name) end
```

- [ ] **Step 9: Verify and commit**

```bash
ls types/cc-tweaked/rednet.lua types/cc-tweaked/peripheral.lua types/cc-tweaked/gps.lua types/cc-tweaked/disk.lua types/cc-tweaked/peripherals/monitor.lua types/cc-tweaked/peripherals/modem.lua types/cc-tweaked/peripherals/speaker.lua types/cc-tweaked/peripherals/printer.lua
```

```bash
git add types/cc-tweaked/rednet.lua types/cc-tweaked/peripheral.lua types/cc-tweaked/gps.lua types/cc-tweaked/disk.lua types/cc-tweaked/peripherals/
git commit -m "feat: CC:Tweaked type stubs — networking & peripherals"
```

---

## Task 4: CC:Tweaked Core Type Stubs — Data & Utilities

**Files:**
- Create: `types/cc-tweaked/textutils.lua`
- Create: `types/cc-tweaked/colors.lua`
- Create: `types/cc-tweaked/keys.lua`
- Create: `types/cc-tweaked/settings.lua`
- Create: `types/cc-tweaked/paintutils.lua`
- Create: `types/cc-tweaked/parallel.lua`
- Create: `types/cc-tweaked/vector.lua`

- [ ] **Step 1: Create types/cc-tweaked/textutils.lua**

```lua
---@meta

---The textutils API for text formatting and serialization.
---@class textutilsAPI
textutils = {}

---Write text slowly, character by character.
---Yields.
---@param text string The text to write
---@param rate? number Characters per second (default 20)
function textutils.slowWrite(text, rate) end

---Print text slowly, character by character.
---Yields.
---@param text string The text to print
---@param rate? number Characters per second (default 20)
function textutils.slowPrint(text, rate) end

---Format an in-game time as a string.
---@param time number The in-game time (0.0 to 24.0)
---@param twentyFour? boolean Use 24-hour format (default false)
---@return string formatted The formatted time string
---@nodiscard
function textutils.formatTime(time, twentyFour) end

---Print text with pagination.
---Yields.
---@param text string The text to print
---@param freeLines? number Lines to reserve at bottom
---@return number linesWritten
function textutils.pagedPrint(text, freeLines) end

---Display data in tabular format.
---@param ... string[]|number Values or color-prefixed rows
function textutils.tabulate(...) end

---Display data in paginated tabular format.
---Yields.
---@param ... string[]|number Values or color-prefixed rows
function textutils.pagedTabulate(...) end

---Serialize a Lua value to a string.
---@param value any The value to serialize
---@param options? {compact?: boolean, allow_repetitions?: boolean} Serialization options
---@return string serialized The serialized string
---@nodiscard
function textutils.serialize(value, options) end

---@param value any
---@param options? {compact?: boolean, allow_repetitions?: boolean}
---@return string
---@nodiscard
function textutils.serialise(value, options) end

---Deserialize a string back to a Lua value.
---@param str string The serialized string
---@return any|nil value The deserialized value, or nil on failure
function textutils.unserialize(str) end

---@param str string
---@return any|nil
function textutils.unserialise(str) end

---Serialize a value to JSON.
---@param value any The value to serialize
---@param unquoteKeys? boolean Whether to leave keys unquoted (for JSONC)
---@return string json The JSON string
---@nodiscard
function textutils.serializeJSON(value, unquoteKeys) end

---@param value any
---@param unquoteKeys? boolean
---@return string
---@nodiscard
function textutils.serialiseJSON(value, unquoteKeys) end

---Deserialize a JSON string.
---@param str string The JSON string
---@param options? {parse_null?: boolean, parse_empty_array?: boolean, nbt_style?: boolean}
---@return any|nil value The deserialized value, or nil on failure
---@return string|nil error Error message on failure
function textutils.unserializeJSON(str, options) end

---@param str string
---@param options? {parse_null?: boolean, parse_empty_array?: boolean, nbt_style?: boolean}
---@return any|nil
---@return string|nil
function textutils.unserialiseJSON(str, options) end

---URL-encode a string.
---@param str string The string to encode
---@return string encoded The URL-encoded string
---@nodiscard
function textutils.urlEncode(str) end

---Complete a partial string against a table of options.
---@param searchText string The partial text
---@param searchTable? table The table to search in (default _G)
---@return string[] completions
---@nodiscard
function textutils.complete(searchText, searchTable) end

---Sentinel value representing an empty JSON array.
---Use this in tables that should serialize as [] instead of {}.
---@type table
textutils.empty_json_array = {}
```

- [ ] **Step 2: Create types/cc-tweaked/colors.lua**

```lua
---@meta

---The colors API. Color values are powers of 2 for use as bitmasks.
---@class colorsAPI
colors = {}

---@type number
colors.white = 1
---@type number
colors.orange = 2
---@type number
colors.magenta = 4
---@type number
colors.lightBlue = 8
---@type number
colors.yellow = 16
---@type number
colors.lime = 32
---@type number
colors.pink = 64
---@type number
colors.gray = 128
---@type number
colors.lightGray = 256
---@type number
colors.cyan = 512
---@type number
colors.purple = 1024
---@type number
colors.blue = 2048
---@type number
colors.brown = 4096
---@type number
colors.green = 8192
---@type number
colors.red = 16384
---@type number
colors.black = 32768

---Combine multiple colors into a bitmask.
---@param ... number Color values to combine
---@return number combined The combined bitmask
---@nodiscard
function colors.combine(...) end

---Remove colors from a bitmask.
---@param col number The color bitmask
---@param ... number Colors to remove
---@return number result The resulting bitmask
---@nodiscard
function colors.subtract(col, ...) end

---Test if a color is in a bitmask.
---@param col number The color bitmask
---@param color number The color to test for
---@return boolean present
---@nodiscard
function colors.test(col, color) end

---Pack RGB values (0-1) into a single number.
---@param r number Red (0-1)
---@param g number Green (0-1)
---@param b number Blue (0-1)
---@return number packed
---@nodiscard
function colors.packRGB(r, g, b) end

---Unpack a packed RGB number into components.
---@param rgb number The packed color
---@return number r Red (0-1)
---@return number g Green (0-1)
---@return number b Blue (0-1)
---@nodiscard
function colors.unpackRGB(rgb) end

---Convert a color to a blit hex character.
---@param color number A single color value
---@return string blit A single hex character (0-f)
---@nodiscard
function colors.toBlit(color) end

---Convert a blit hex character to a color.
---@param blit string A single hex character (0-f)
---@return number color The color value
---@nodiscard
function colors.fromBlit(blit) end

---British English alias for colors.
---@type colorsAPI
colours = colors
```

- [ ] **Step 3: Create types/cc-tweaked/keys.lua**

```lua
---@meta

---The keys API provides key code constants.
---@class keysAPI
keys = {}

---Get the name of a key code.
---@param key number The key code
---@return string|nil name The key name
---@nodiscard
function keys.getName(key) end

---@type number
keys.a, keys.b, keys.c, keys.d, keys.e, keys.f, keys.g, keys.h, keys.i = 30, 48, 46, 32, 18, 33, 34, 35, 23
---@type number
keys.j, keys.k, keys.l, keys.m, keys.n, keys.o, keys.p, keys.q, keys.r = 36, 37, 38, 50, 49, 24, 25, 16, 19
---@type number
keys.s, keys.t, keys.u, keys.v, keys.w, keys.x, keys.y, keys.z = 31, 20, 22, 47, 17, 45, 21, 44

---@type number
keys.zero, keys.one, keys.two, keys.three, keys.four = 11, 2, 3, 4, 5
---@type number
keys.five, keys.six, keys.seven, keys.eight, keys.nine = 6, 7, 8, 9, 10

---@type number
keys.enter = 28
---@type number
keys.space = 57
---@type number
keys.backspace = 14
---@type number
keys.tab = 15
---@type number
keys.leftShift = 42
---@type number
keys.rightShift = 54
---@type number
keys.leftCtrl = 29
---@type number
keys.rightCtrl = 157
---@type number
keys.leftAlt = 56
---@type number
keys.rightAlt = 184
---@type number
keys.up = 200
---@type number
keys.down = 208
---@type number
keys.left = 203
---@type number
keys.right = 205
---@type number
keys.home = 199
---@type number
keys["end"] = 207
---@type number
keys.pageUp = 201
---@type number
keys.pageDown = 209
---@type number
keys.insert = 210
---@type number
keys.delete = 211
---@type number
keys.capsLock = 58
---@type number
keys.numLock = 69
---@type number
keys.scrollLock = 70
---@type number
keys.f1, keys.f2, keys.f3, keys.f4, keys.f5 = 59, 60, 61, 62, 63
---@type number
keys.f6, keys.f7, keys.f8, keys.f9, keys.f10 = 64, 65, 66, 67, 68
---@type number
keys.f11, keys.f12 = 87, 88
---@type number
keys.escape = 1
---@type number
keys.minus = 12
---@type number
keys.equals = 13
---@type number
keys.leftBracket = 26
---@type number
keys.rightBracket = 27
---@type number
keys.backslash = 43
---@type number
keys.semicolon = 39
---@type number
keys.apostrophe = 40
---@type number
keys.grave = 41
---@type number
keys.comma = 51
---@type number
keys.period = 52
---@type number
keys.slash = 53
```

- [ ] **Step 4: Create types/cc-tweaked/settings.lua**

```lua
---@meta

---The settings API for persistent key-value configuration.
---@class settingsAPI
settings = {}

---Define a setting with metadata.
---@param name string The setting name
---@param options? {description?: string, default?: any, type?: string}
function settings.define(name, options) end

---Remove a setting definition.
---@param name string The setting name
function settings.undefine(name) end

---Set a setting value.
---@param name string The setting name
---@param value any The value to set
function settings.set(name, value) end

---Get a setting value.
---@param name string The setting name
---@param default? any Default if not set
---@return any value The setting value
function settings.get(name, default) end

---Remove a setting value (revert to default).
---@param name string The setting name
function settings.unset(name) end

---Clear all settings.
function settings.clear() end

---Get all setting names.
---@return string[] names
---@nodiscard
function settings.getNames() end

---Get details about a setting.
---@param name string The setting name
---@return {description?: string, default?: any, type?: string, value?: any} details
---@nodiscard
function settings.getDetails(name) end

---Load settings from a file.
---@param path? string The file path (default ".settings")
---@return boolean success
function settings.load(path) end

---Save settings to a file.
---@param path? string The file path (default ".settings")
---@return boolean success
function settings.save(path) end
```

- [ ] **Step 5: Create types/cc-tweaked/paintutils.lua**

```lua
---@meta

---The paintutils API for drawing images and shapes.
---@class paintutilsAPI
paintutils = {}

---Parse an image from a string.
---@param data string The image data (paint format)
---@return table image The parsed image
---@nodiscard
function paintutils.parseImage(data) end

---Load an image from a file.
---@param path string The file path
---@return table|nil image The loaded image, or nil on failure
function paintutils.loadImage(path) end

---Draw a single pixel.
---@param x number X position
---@param y number Y position
---@param color? number The color (default current background)
function paintutils.drawPixel(x, y, color) end

---Draw a line between two points.
---@param startX number Start X
---@param startY number Start Y
---@param endX number End X
---@param endY number End Y
---@param color? number The color
function paintutils.drawLine(startX, startY, endX, endY, color) end

---Draw a box outline.
---@param startX number Top-left X
---@param startY number Top-left Y
---@param endX number Bottom-right X
---@param endY number Bottom-right Y
---@param color? number The color
function paintutils.drawBox(startX, startY, endX, endY, color) end

---Draw a filled box.
---@param startX number Top-left X
---@param startY number Top-left Y
---@param endX number Bottom-right X
---@param endY number Bottom-right Y
---@param color? number The color
function paintutils.drawFilledBox(startX, startY, endX, endY, color) end

---Draw an image at a position.
---@param image table The image from parseImage/loadImage
---@param x number X position
---@param y number Y position
function paintutils.drawImage(image, x, y) end
```

- [ ] **Step 6: Create types/cc-tweaked/parallel.lua**

```lua
---@meta

---The parallel API for running functions concurrently using coroutines.
---@class parallelAPI
parallel = {}

---Run all functions simultaneously, waiting for all to finish.
---Yields.
---@param ... fun() Functions to run
function parallel.waitForAll(...) end

---Run all functions simultaneously, returning when any finishes.
---Yields.
---@param ... fun() Functions to run
function parallel.waitForAny(...) end
```

- [ ] **Step 7: Create types/cc-tweaked/vector.lua**

```lua
---@meta

---A 3D vector type.
---@class vector
---@field x number
---@field y number
---@field z number
---@operator add(vector): vector
---@operator sub(vector): vector
---@operator mul(number): vector
---@operator unm: vector
local vectorInstance = {}

---Add another vector.
---@param o vector The vector to add
---@return vector result
---@nodiscard
function vectorInstance:add(o) end

---Subtract another vector.
---@param o vector The vector to subtract
---@return vector result
---@nodiscard
function vectorInstance:sub(o) end

---Multiply by a scalar.
---@param factor number The scalar
---@return vector result
---@nodiscard
function vectorInstance:mul(factor) end

---Divide by a scalar.
---@param factor number The scalar
---@return vector result
---@nodiscard
function vectorInstance:div(factor) end

---Negate the vector.
---@return vector result
---@nodiscard
function vectorInstance:unm() end

---Dot product.
---@param o vector The other vector
---@return number dot
---@nodiscard
function vectorInstance:dot(o) end

---Cross product.
---@param o vector The other vector
---@return vector cross
---@nodiscard
function vectorInstance:cross(o) end

---Get the length of the vector.
---@return number length
---@nodiscard
function vectorInstance:length() end

---Normalize the vector to unit length.
---@return vector normalized
---@nodiscard
function vectorInstance:normalize() end

---Round to the nearest integer coordinates.
---@param tolerance? number Rounding tolerance (default 0.5)
---@return vector rounded
---@nodiscard
function vectorInstance:round(tolerance) end

---Convert to a string.
---@return string str e.g. "1, 2, 3"
---@nodiscard
function vectorInstance:tostring() end

---Create a new vector.
---@param x number
---@param y number
---@param z number
---@return vector
---@nodiscard
function vector.new(x, y, z) end
```

- [ ] **Step 8: Verify and commit**

```bash
ls types/cc-tweaked/textutils.lua types/cc-tweaked/colors.lua types/cc-tweaked/keys.lua types/cc-tweaked/settings.lua types/cc-tweaked/paintutils.lua types/cc-tweaked/parallel.lua types/cc-tweaked/vector.lua
```

```bash
git add types/cc-tweaked/textutils.lua types/cc-tweaked/colors.lua types/cc-tweaked/keys.lua types/cc-tweaked/settings.lua types/cc-tweaked/paintutils.lua types/cc-tweaked/parallel.lua types/cc-tweaked/vector.lua
git commit -m "feat: CC:Tweaked type stubs — data & utilities"
```

---

## Task 5: CC:Tweaked Core Type Stubs — Shell, Turtle, Pocket, Redstone

**Files:**
- Create: `types/cc-tweaked/shell.lua`
- Create: `types/cc-tweaked/multishell.lua`
- Create: `types/cc-tweaked/turtle.lua`
- Create: `types/cc-tweaked/pocket.lua`
- Create: `types/cc-tweaked/redstone.lua`

- [ ] **Step 1: Create types/cc-tweaked/shell.lua**

```lua
---@meta

---The shell API for running and managing programs.
---@class shellAPI
shell = {}

---Run a program.
---Yields.
---@param command string The program name
---@param ... string Arguments
---@return boolean success
function shell.run(command, ...) end

---Run a program in a specific environment.
---Yields.
---@param command string The program name
---@param ... string Arguments
---@return boolean success
function shell.execute(command, ...) end

---Exit the current shell.
function shell.exit() end

---Get the current working directory.
---@return string dir The current directory
---@nodiscard
function shell.dir() end

---Set the current working directory.
---@param path string The new directory
function shell.setDir(path) end

---Get the shell's program search path.
---@return string path The colon-separated path
---@nodiscard
function shell.path() end

---Set the shell's program search path.
---@param path string The colon-separated path
function shell.setPath(path) end

---Resolve a relative path to an absolute path.
---@param path string The relative path
---@return string absolute The absolute path
---@nodiscard
function shell.resolve(path) end

---Resolve a program name to its path.
---@param name string The program name
---@return string|nil path The program path, or nil if not found
---@nodiscard
function shell.resolveProgram(name) end

---Get all shell aliases.
---@return table<string, string> aliases Map of alias to program
---@nodiscard
function shell.aliases() end

---Set a shell alias.
---@param alias string The alias name
---@param program string The program to alias to
function shell.setAlias(alias, program) end

---Remove a shell alias.
---@param alias string The alias to remove
function shell.clearAlias(alias) end

---List available programs.
---@param showHidden? boolean Include hidden programs
---@return string[] programs Program names
---@nodiscard
function shell.programs(showHidden) end

---Get completions for a command line.
---@param line string The partial command line
---@return string[]|nil completions
---@nodiscard
function shell.complete(line) end

---Complete a program name.
---@param prefix string The partial program name
---@return string[] completions
---@nodiscard
function shell.completeProgram(prefix) end

---Get the currently running program.
---@return string path The program path
---@nodiscard
function shell.getRunningProgram() end

---Switch to a different multishell tab.
---@param id number The tab ID
function shell.switchTab(id) end

---Open a new tab running a program.
---@param command string The program name
---@param ... string Arguments
---@return number tabID The new tab's ID
function shell.openTab(command, ...) end
```

- [ ] **Step 2: Create types/cc-tweaked/multishell.lua**

```lua
---@meta

---The multishell API for tab management (advanced computers only).
---@class multishellAPI
multishell = {}

---Get the ID of the current tab.
---@return number id
---@nodiscard
function multishell.getCurrent() end

---Get the number of tabs.
---@return number count
---@nodiscard
function multishell.getCount() end

---Launch a new tab.
---@param env table The environment for the new program
---@param path string The program path
---@param ... string Arguments
---@return number id The new tab's ID
function multishell.launch(env, path, ...) end

---Set the title of a tab.
---@param id number The tab ID
---@param title string The new title
function multishell.setTitle(id, title) end

---Get the title of a tab.
---@param id number The tab ID
---@return string|nil title The tab title
---@nodiscard
function multishell.getTitle(id) end

---Set the focused tab.
---@param id number The tab ID
---@return boolean success
function multishell.setFocus(id) end

---Get the focused tab.
---@return number id The focused tab ID
---@nodiscard
function multishell.getFocus() end
```

- [ ] **Step 3: Create types/cc-tweaked/turtle.lua**

```lua
---@meta

---The turtle API for controlling turtle robots.
---Only available on turtle computers.
---@class turtleAPI
turtle = {}

---Move the turtle forward one block.
---Yields.
---@return boolean success
---@return string|nil error Error message on failure
function turtle.forward() end

---Move the turtle backward one block.
---Yields.
---@return boolean success
---@return string|nil error
function turtle.back() end

---Move the turtle up one block.
---Yields.
---@return boolean success
---@return string|nil error
function turtle.up() end

---Move the turtle down one block.
---Yields.
---@return boolean success
---@return string|nil error
function turtle.down() end

---Turn left 90 degrees.
---Yields.
---@return boolean success
---@return string|nil error
function turtle.turnLeft() end

---Turn right 90 degrees.
---Yields.
---@return boolean success
---@return string|nil error
function turtle.turnRight() end

---Dig the block in front.
---Yields.
---@param side? string The tool side ("left" or "right")
---@return boolean success
---@return string|nil error
function turtle.dig(side) end

---Dig the block above.
---Yields.
---@param side? string The tool side
---@return boolean success
---@return string|nil error
function turtle.digUp(side) end

---Dig the block below.
---Yields.
---@param side? string The tool side
---@return boolean success
---@return string|nil error
function turtle.digDown(side) end

---Place a block in front.
---Yields.
---@param text? string Sign text if placing a sign
---@return boolean success
---@return string|nil error
function turtle.place(text) end

---Place a block above.
---Yields.
---@param text? string Sign text
---@return boolean success
---@return string|nil error
function turtle.placeUp(text) end

---Place a block below.
---Yields.
---@param text? string Sign text
---@return boolean success
---@return string|nil error
function turtle.placeDown(text) end

---Select an inventory slot.
---@param slot number The slot (1-16)
---@return boolean success
function turtle.select(slot) end

---Get the currently selected slot.
---@return number slot The selected slot (1-16)
---@nodiscard
function turtle.getSelectedSlot() end

---Get the item count in a slot.
---@param slot? number The slot (default: selected)
---@return number count
---@nodiscard
function turtle.getItemCount(slot) end

---Get the remaining space in a slot.
---@param slot? number The slot (default: selected)
---@return number space
---@nodiscard
function turtle.getItemSpace(slot) end

---Get details about an item in a slot.
---@param slot? number The slot (default: selected)
---@param detailed? boolean Get full item details
---@return table|nil detail Item details table with name, count, damage; nil if empty
---@nodiscard
function turtle.getItemDetail(slot, detailed) end

---Equip the item in the selected slot to the left.
---Yields.
---@return boolean success
---@return string|nil error
function turtle.equipLeft() end

---Equip the item in the selected slot to the right.
---Yields.
---@return boolean success
---@return string|nil error
function turtle.equipRight() end

---Drop items from the selected slot in front.
---Yields.
---@param count? number How many to drop (default: all)
---@return boolean success
---@return string|nil error
function turtle.drop(count) end

---Drop items above.
---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.dropUp(count) end

---Drop items below.
---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.dropDown(count) end

---Pick up items from in front.
---Yields.
---@param count? number Max items to pick up
---@return boolean success
---@return string|nil error
function turtle.suck(count) end

---Pick up items from above.
---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.suckUp(count) end

---Pick up items from below.
---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.suckDown(count) end

---Consume fuel from the selected slot.
---Yields.
---@param count? number How many items to consume
---@return boolean success
---@return string|nil error
function turtle.refuel(count) end

---Get the current fuel level.
---@return number|"unlimited" level Fuel units remaining
---@nodiscard
function turtle.getFuelLevel() end

---Get the maximum fuel level.
---@return number|"unlimited" limit Max fuel capacity
---@nodiscard
function turtle.getFuelLimit() end

---Check if there's a block in front.
---@return boolean detected
function turtle.detect() end

---Check if there's a block above.
---@return boolean detected
function turtle.detectUp() end

---Check if there's a block below.
---@return boolean detected
function turtle.detectDown() end

---Inspect the block in front.
---@return boolean success True if a block is present
---@return table info Block info with name, state, tags fields
function turtle.inspect() end

---Inspect the block above.
---@return boolean success
---@return table info
function turtle.inspectUp() end

---Inspect the block below.
---@return boolean success
---@return table info
function turtle.inspectDown() end

---Transfer items to another slot.
---@param slot number The destination slot (1-16)
---@param count? number How many to transfer
---@return boolean success
function turtle.transferTo(slot, count) end

---Craft items using a crafting table (requires crafting table equipped).
---Yields.
---@param limit? number Max items to craft
---@return boolean success
---@return string|nil error
function turtle.craft(limit) end
```

- [ ] **Step 4: Create types/cc-tweaked/pocket.lua**

```lua
---@meta

---The pocket API for pocket computers.
---Only available on pocket computers.
---@class pocketAPI
pocket = {}

---Equip the item in the selected slot to the back.
---@return boolean success
---@return string|nil error
function pocket.equipBack() end

---Unequip the item from the back.
---@return boolean success
---@return string|nil error
function pocket.unequipBack() end
```

- [ ] **Step 5: Create types/cc-tweaked/redstone.lua**

```lua
---@meta

---The redstone API for interacting with redstone signals.
---@class redstoneAPI
redstone = {}

---Get valid sides.
---@return string[] sides e.g. {"top", "bottom", "left", "right", "front", "back"}
---@nodiscard
function redstone.getSides() end

---Get digital redstone input on a side.
---@param side string The side
---@return boolean on Whether there is a signal
---@nodiscard
function redstone.getInput(side) end

---Set digital redstone output on a side.
---@param side string The side
---@param on boolean Whether to output a signal
function redstone.setOutput(side, on) end

---Get digital redstone output on a side.
---@param side string The side
---@return boolean on
---@nodiscard
function redstone.getOutput(side) end

---Get analog redstone input strength.
---@param side string The side
---@return number strength Signal strength (0-15)
---@nodiscard
function redstone.getAnalogInput(side) end

---Set analog redstone output strength.
---@param side string The side
---@param strength number Signal strength (0-15)
function redstone.setAnalogOutput(side, strength) end

---Get analog redstone output strength.
---@param side string The side
---@return number strength
---@nodiscard
function redstone.getAnalogOutput(side) end

---Get bundled cable input.
---@param side string The side
---@return number colors Combined color bitmask
---@nodiscard
function redstone.getBundledInput(side) end

---Set bundled cable output.
---@param side string The side
---@param colors number Combined color bitmask
function redstone.setBundledOutput(side, colors) end

---Get bundled cable output.
---@param side string The side
---@return number colors Combined color bitmask
---@nodiscard
function redstone.getBundledOutput(side) end

---Test if specific colors are active in bundled input.
---@param side string The side
---@param mask number Color bitmask to test
---@return boolean active
---@nodiscard
function redstone.testBundledInput(side, mask) end

---Alias for redstone.
---@type redstoneAPI
rs = redstone
```

- [ ] **Step 6: Verify and commit**

```bash
ls types/cc-tweaked/shell.lua types/cc-tweaked/multishell.lua types/cc-tweaked/turtle.lua types/cc-tweaked/pocket.lua types/cc-tweaked/redstone.lua
```

```bash
git add types/cc-tweaked/shell.lua types/cc-tweaked/multishell.lua types/cc-tweaked/turtle.lua types/cc-tweaked/pocket.lua types/cc-tweaked/redstone.lua
git commit -m "feat: CC:Tweaked type stubs — shell, turtle, pocket, redstone"
```

---

## Task 6: CC:Sable Type Stubs

**Files:**
- Create: `types/cc-sable/aero.lua`
- Create: `types/cc-sable/sublevel.lua`

- [ ] **Step 1: Create types/cc-sable/aero.lua**

```lua
---@meta

---The aero (aerodynamics) API from CC:Sable.
---Provides access to dimensional physics information from Sable.
---Available on all computers in Sable-enabled dimensions.
---@class aeroAPI
aero = {}

---Gets the air pressure at the given position.
---@param position vector The position to sample
---@return number pressure The air pressure at that position
function aero.getAirPressure(position) end

---Gets the dimension's gravity vector.
---@return vector gravity The gravity vector
---@nodiscard
function aero.getGravity() end

---Gets the dimension's magnetic north vector.
---@return vector magneticNorth The magnetic north direction
---@nodiscard
function aero.getMagneticNorth() end

---Gets the universal drag constant for the dimension.
---@return number drag The drag constant
---@nodiscard
function aero.getUniversalDrag() end

---Gets raw physics information of the dimension (JSON config values).
---@return {gravity?: vector, basePressure?: number, magneticNorth?: vector, universalDrag?: number} raw
---@nodiscard
function aero.getRaw() end

---Gets default physics information for the dimension.
---@return {gravity?: vector, basePressure?: number, magneticNorth?: vector, universalDrag?: number} defaults
---@nodiscard
function aero.getDefault() end

---Alias for aero.
---@type aeroAPI
aerodynamics = aero
```

- [ ] **Step 2: Create types/cc-sable/sublevel.lua**

Use the exact stub from the spec (already validated during design):

```lua
---@meta

---Sub-Level API for Create: Aeronautics contraptions.
---Only available on computers physically on a Sub-Level.
---Added by CC:Sable. Also provides the `quaternion` API via CC: Advanced Math.
---@class sublevelAPI
sublevel = {}

---Check if this computer is on a Sub-Level.
---@return boolean onSubLevel true if on a Sub-Level
function sublevel.isInPlotGrid() end

---Get the Sub-Level's UUID.
---@return string uuid The Sub-Level's UUID
---@nodiscard
---Errors if computer is not on a Sub-Level.
function sublevel.getUniqueId() end

---Get the Sub-Level's name.
---@return string name The Sub-Level's name
---@nodiscard
---Errors if computer is not on a Sub-Level.
function sublevel.getName() end

---Set the Sub-Level's name.
---@param newName string The new name
---Errors if computer is not on a Sub-Level.
function sublevel.setName(newName) end

---Get the logical pose of the Sub-Level.
---@return {position: vector, orientation: quaternion, scale: vector, rotationPoint: vector} pose
---Errors if computer is not on a Sub-Level.
function sublevel.getLogicalPose() end

---Get the last rendered pose of the Sub-Level.
---@return {position: vector, orientation: quaternion, scale: vector, rotationPoint: vector} pose
---Errors if computer is not on a Sub-Level.
function sublevel.getLastPose() end

---Get the global velocity of the Sub-Level.
---@return vector velocity
function sublevel.getVelocity() end

---Get the latest linear velocity.
---@return vector linearVelocity
---Errors if computer is not on a Sub-Level.
function sublevel.getLinearVelocity() end

---Get the latest angular velocity.
---@return vector angularVelocity
---Errors if computer is not on a Sub-Level.
function sublevel.getAngularVelocity() end

---Get the center of mass.
---@return vector centerOfMass
---Errors if computer is not on a Sub-Level.
function sublevel.getCenterOfMass() end

---Get the mass.
---@return number mass
---Errors if computer is not on a Sub-Level.
function sublevel.getMass() end

---Get the inverse mass.
---@return number inverseMass
---Errors if computer is not on a Sub-Level.
function sublevel.getInverseMass() end

---Get the inertia tensor.
---@return table inertiaTensor 3x3 matrix as nested tables
---Errors if computer is not on a Sub-Level.
function sublevel.getInertiaTensor() end

---Get the inverse inertia tensor.
---@return table inverseInertiaTensor 3x3 matrix as nested tables
---Errors if computer is not on a Sub-Level.
function sublevel.getInverseInertiaTensor() end
```

- [ ] **Step 3: Verify and commit**

```bash
ls types/cc-sable/aero.lua types/cc-sable/sublevel.lua
```

```bash
git add types/cc-sable/
git commit -m "feat: CC:Sable type stubs — aero and sublevel APIs"
```

---

## Task 7: CC:C Bridge Type Stubs

**Files:**
- Create: `types/ccc-bridge/source.lua`
- Create: `types/ccc-bridge/red-router.lua`
- Create: `types/ccc-bridge/animatronic.lua`
- Create: `types/ccc-bridge/scroller-pane.lua`

- [ ] **Step 1: Create types/ccc-bridge/source.lua**

```lua
---@meta

---The Source Block peripheral from CC:C Bridge.
---Acts like a terminal — text written here is displayed via Create Display Links.
---Peripheral type: "create_source"
---@class CreateSource
local CreateSource = {}

---Get the display size.
---@return number width
---@return number height
---@nodiscard
function CreateSource:getSize() end

---Clear the display.
function CreateSource:clear() end

---Set the cursor position.
---@param x number X position (1-based)
---@param y number Y position (1-based)
function CreateSource:setCursorPos(x, y) end

---Get the cursor position.
---@return number x
---@return number y
---@nodiscard
function CreateSource:getCursorPos() end

---Write text at the current cursor position.
---@param text string The text to write
function CreateSource:write(text) end

---Set the background color (ignored — Source has no color support).
---@param color number
function CreateSource:setBackgroundColor(color) end

---Set the text color (ignored — Source has no color support).
---@param color number
function CreateSource:setTextColor(color) end

---Get the text content of a line.
---@param lineNumber number The line number (1-based)
---@return string text The text content of the line
---@nodiscard
function CreateSource:getLine(lineNumber) end

---Clear the current line.
function CreateSource:clearLine() end
```

- [ ] **Step 2: Create types/ccc-bridge/red-router.lua**

```lua
---@meta

---The RedRouter peripheral from CC:C Bridge.
---Remote redstone control through Create's extended cable networks.
---Peripheral type: "redrouter"
---@class RedRouter
local RedRouter = {}

---Set digital redstone output on a side.
---@param side string The side
---@param on boolean Whether to output a signal
function RedRouter:setOutput(side, on) end

---Set analog redstone output strength on a side.
---@param side string The side
---@param value number Signal strength (0-15)
---Errors if value is outside 0-15 range.
function RedRouter:setAnalogOutput(side, value) end

---Get digital redstone output on a side.
---@param side string The side
---@return boolean on
---@nodiscard
function RedRouter:getOutput(side) end

---Get digital redstone input on a side.
---@param side string The side
---@return boolean on
---@nodiscard
function RedRouter:getInput(side) end

---Get analog redstone output strength on a side.
---@param side string The side
---@return number strength (0-15)
---@nodiscard
function RedRouter:getAnalogOutput(side) end

---Get analog redstone input strength on a side.
---@param side string The side
---@return number strength (0-15)
---@nodiscard
function RedRouter:getAnalogInput(side) end
```

- [ ] **Step 3: Create types/ccc-bridge/animatronic.lua**

```lua
---@meta

---The Animatronic peripheral from CC:C Bridge.
---Controls expressive robot puppets with face expressions and limb rotations.
---Peripheral type: "animatronic"
---@class Animatronic
local Animatronic = {}

---Set the puppet's facial expression.
---@param face string One of: "normal", "happy", "question", "sad"
function Animatronic:setFace(face) end

---Set the animation transition mode.
---@param kind string One of: "linear", "none" (instant), "rusty"
function Animatronic:setTransition(kind) end

---Apply stored rotation values to the animatronic. Resets stored rotations to 0.
function Animatronic:push() end

---Set head rotation.
---@param x number X rotation (-180 to 180)
---@param y number Y rotation (-180 to 180)
---@param z number Z rotation (-180 to 180)
function Animatronic:setHeadRot(x, y, z) end

---Set body rotation.
---@param x number X rotation (-360 to 360)
---@param y number Y rotation (-180 to 180)
---@param z number Z rotation (-180 to 180)
function Animatronic:setBodyRot(x, y, z) end

---Set left arm rotation.
---@param x number X rotation (-180 to 180)
---@param y number Y rotation (-180 to 180)
---@param z number Z rotation (-180 to 180)
function Animatronic:setLeftArmRot(x, y, z) end

---Set right arm rotation.
---@param x number X rotation (-180 to 180)
---@param y number Y rotation (-180 to 180)
---@param z number Z rotation (-180 to 180)
function Animatronic:setRightArmRot(x, y, z) end

---Get the stored (not yet applied) head rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredHeadRot() end

---Get the stored body rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredBodyRot() end

---Get the stored left arm rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredLeftArmRot() end

---Get the stored right arm rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredRightArmRot() end

---Get the applied (currently displayed) head rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedHeadRot() end

---Get the applied body rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedBodyRot() end

---Get the applied left arm rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedLeftArmRot() end

---Get the applied right arm rotation.
---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedRightArmRot() end
```

- [ ] **Step 4: Create types/ccc-bridge/scroller-pane.lua**

```lua
---@meta

---The Scroller Pane peripheral from CC:C Bridge.
---A scrollable text display.
---Peripheral type: "scroller_pane"
---@class ScrollerPane
local ScrollerPane = {}

---Get the display size.
---@return number width
---@return number height
---@nodiscard
function ScrollerPane:getSize() end

---Clear the display.
function ScrollerPane:clear() end

---Set the cursor position.
---@param x number
---@param y number
function ScrollerPane:setCursorPos(x, y) end

---Get the cursor position.
---@return number x
---@return number y
---@nodiscard
function ScrollerPane:getCursorPos() end

---Write text at the cursor position.
---@param text string
function ScrollerPane:write(text) end

---Clear the current line.
function ScrollerPane:clearLine() end
```

- [ ] **Step 5: Verify and commit**

```bash
ls types/ccc-bridge/
```

```bash
git add types/ccc-bridge/
git commit -m "feat: CC:C Bridge type stubs — source, RedRouter, animatronic, scroller pane"
```

---

## Task 8: CC: Direct GPU Type Stubs

**Files:**
- Create: `types/direct-gpu/gpu.lua`
- Create: `types/direct-gpu/map-reader.lua`

This is the largest single stub file (130+ functions). Organized into sections matching the DirectGPU README.

- [ ] **Step 1: Create types/direct-gpu/gpu.lua**

```lua
---@meta

---The DirectGPU peripheral for high-performance graphics rendering.
---Peripheral type: "directgpu"
---@class DirectGPU
local DirectGPU = {}

-- ============================================================================
-- region Display Management
-- ============================================================================

---Auto-detect a nearby monitor and create a display on it.
---@return number displayId The new display ID
function DirectGPU:autoDetectAndCreateDisplay() end

---Auto-detect and create display with custom resolution multiplier.
---@param resolutionMultiplier number Resolution scale factor
---@return number displayId
function DirectGPU:autoDetectAndCreateDisplayWithResolution(resolutionMultiplier) end

---Auto-detect the nearest monitor.
---@return string monitorName The monitor's peripheral name
---@nodiscard
function DirectGPU:autoDetectMonitor() end

---Remove all displays.
function DirectGPU:clearAllDisplays() end

---Create a display at specific world coordinates.
---@param x number World X
---@param y number World Y
---@param z number World Z
---@param facing string Direction the display faces
---@param width number Width in blocks
---@param height number Height in blocks
---@return number displayId
function DirectGPU:createDisplay(x, y, z, facing, width, height) end

---Create a display at specific coordinates (alias).
---@param x number World X
---@param y number World Y
---@param z number World Z
---@param facing string Direction
---@param width number Width in blocks
---@param height number Height in blocks
---@return number displayId
function DirectGPU:createDisplayAt(x, y, z, facing, width, height) end

---Create a display with custom resolution.
---@param x number World X
---@param y number World Y
---@param z number World Z
---@param facing string Direction
---@param width number Width in blocks
---@param height number Height in blocks
---@param resolutionMultiplier number Resolution scale
---@return number displayId
function DirectGPU:createDisplayWithResolution(x, y, z, facing, width, height, resolutionMultiplier) end

---Get information about a display.
---@param displayId number The display ID
---@return string info JSON string with display info (pixelWidth, pixelHeight, etc.)
---@nodiscard
function DirectGPU:getDisplayInfo(displayId) end

---Get resource usage statistics.
---@return string stats JSON string with resource stats
---@nodiscard
function DirectGPU:getResourceStats() end

---List all active displays.
---@return table displays List of display info
---@nodiscard
function DirectGPU:listDisplays() end

---Remove a display.
---@param displayId number The display to remove
---@return boolean success
function DirectGPU:removeDisplay(displayId) end

---Set whether a display persists across computer restarts.
---@param displayId number
---@param persistent boolean
function DirectGPU:setDisplayPersistent(displayId, persistent) end

---Flush the display buffer to the screen. Call after drawing.
---@param displayId number
function DirectGPU:updateDisplay(displayId) end

-- endregion

-- ============================================================================
-- region 2D Drawing
-- ============================================================================

---Clear the display to a solid color.
---@param displayId number
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:clear(displayId, r, g, b) end

---Draw a circle.
---@param displayId number
---@param cx number Center X
---@param cy number Center Y
---@param radius number Radius in pixels
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param filled boolean Whether to fill the circle
function DirectGPU:drawCircle(displayId, cx, cy, radius, r, g, b, filled) end

---Draw an ellipse.
---@param displayId number
---@param cx number Center X
---@param cy number Center Y
---@param rx number X radius
---@param ry number Y radius
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param filled boolean
function DirectGPU:drawEllipse(displayId, cx, cy, rx, ry, r, g, b, filled) end

---Draw a line.
---@param displayId number
---@param x1 number Start X
---@param y1 number Start Y
---@param x2 number End X
---@param y2 number End Y
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:drawLine(displayId, x1, y1, x2, y2, r, g, b) end

---Draw a polygon from a list of points.
---@param displayId number
---@param pointsObj table Array of {x, y} points
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:drawPolygon(displayId, pointsObj, r, g, b) end

---Draw connected line segments (polyline).
---@param displayId number
---@param pointsObj table Array of {x, y} points
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:drawPolylines(displayId, pointsObj, r, g, b) end

---Fill an ellipse.
---@param displayId number
---@param cx number Center X
---@param cy number Center Y
---@param rx number X radius
---@param ry number Y radius
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:fillEllipse(displayId, cx, cy, rx, ry, r, g, b) end

---Fill a rectangle.
---@param displayId number
---@param x number Top-left X
---@param y number Top-left Y
---@param w number Width
---@param h number Height
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:fillRect(displayId, x, y, w, h, r, g, b) end

---Get the color of a pixel.
---@param displayId number
---@param x number X position
---@param y number Y position
---@return table pixel Color info {r, g, b}
---@nodiscard
function DirectGPU:getPixel(displayId, x, y) end

---Set a single pixel.
---@param displayId number
---@param x number X position
---@param y number Y position
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:setPixel(displayId, x, y, r, g, b) end

-- endregion

-- ============================================================================
-- region Text Rendering
-- ============================================================================

---Clear the font cache.
function DirectGPU:clearFontCache() end

---Draw text on a display.
---@param displayId number
---@param text string
---@param x number X position
---@param y number Y position
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param fontName string Font name (e.g. "Arial")
---@param fontSize number Font size in points
---@param style string Font style (e.g. "bold", "italic", "plain")
---@return string info Text metrics info
function DirectGPU:drawText(displayId, text, x, y, r, g, b, fontName, fontSize, style) end

---Draw text with a background color.
---@param displayId number
---@param text string
---@param x number
---@param y number
---@param fgR number Foreground red
---@param fgG number Foreground green
---@param fgB number Foreground blue
---@param bgR number Background red
---@param bgG number Background green
---@param bgB number Background blue
---@param padding number Padding around text
---@param fontName string
---@param fontSize number
---@param style string
---@return string info
function DirectGPU:drawTextWithBg(displayId, text, x, y, fgR, fgG, fgB, bgR, bgG, bgB, padding, fontName, fontSize, style) end

---Draw text with word wrapping.
---@param displayId number
---@param text string
---@param x number
---@param y number
---@param maxWidth number Maximum line width in pixels
---@param r number Red
---@param g number Green
---@param b number Blue
---@param lineSpacing number Extra spacing between lines
---@param fontName string
---@param fontSize number
---@param style string
---@return string info
function DirectGPU:drawTextWrapped(displayId, text, x, y, maxWidth, r, g, b, lineSpacing, fontName, fontSize, style) end

---Measure text dimensions without drawing.
---@param text string
---@param fontName string
---@param fontSize number
---@param style string
---@return string info JSON with width, height
---@nodiscard
function DirectGPU:measureText(text, fontName, fontSize, style) end

-- endregion

-- ============================================================================
-- region Image & JPEG
-- ============================================================================

---Clear the JPEG decode cache.
function DirectGPU:clearJPEGCache() end

---Decode and scale a JPEG image.
---@param base64JpegData string Base64-encoded JPEG
---@param targetWidth number Target width
---@param targetHeight number Target height
---@return string result Decoded image info
function DirectGPU:decodeAndScaleJPEG(base64JpegData, targetWidth, targetHeight) end

---Decode a JPEG image.
---@param base64JpegData string Base64-encoded JPEG
---@return string result Decoded image info
function DirectGPU:decodeJPEG(base64JpegData) end

---Get JPEG dimensions without decoding.
---@param base64JpegData string Base64-encoded JPEG
---@return string dimensions JSON with width, height
---@nodiscard
function DirectGPU:getJPEGDimensions(base64JpegData) end

---Get JPEG network statistics.
---@return string stats JSON stats
---@nodiscard
function DirectGPU:getJPEGNetworkStats() end

---Get recommended JPEG settings for a target resolution.
---@param targetWidth number
---@param targetHeight number
---@return string settings JSON settings
---@nodiscard
function DirectGPU:getRecommendedJPEGSettings(targetWidth, targetHeight) end

---Load a JPEG fullscreen on a display.
---@param displayId number
---@param base64JpegData string Base64-encoded JPEG
function DirectGPU:loadJPEGFullscreen(displayId, base64JpegData) end

---Load a JPEG into a region.
---@param displayId number
---@param jpegBinaryData string JPEG binary data
---@param x number Region X
---@param y number Region Y
---@param w number Region width
---@param h number Region height
function DirectGPU:loadJPEGRegion(displayId, jpegBinaryData, x, y, w, h) end

---Load a base64 JPEG into a region.
---@param displayId number
---@param base64JpegData string Base64-encoded JPEG
---@param x number
---@param y number
---@param w number
---@param h number
function DirectGPU:loadJPEGRegionBytes(displayId, base64JpegData, x, y, w, h) end

---Preload a sequence of JPEGs for animation.
---@param displayId number
---@param jpegSequence table Array of base64 JPEG strings
function DirectGPU:preloadJPEGSequence(displayId, jpegSequence) end

-- endregion

-- ============================================================================
-- region Dictionary Compression
-- ============================================================================

---Clear the compression dictionary.
function DirectGPU:clearDictionary() end

---Compress data using the dictionary.
---@param base64Data string Base64-encoded data
---@return string compressed Compressed data reference
function DirectGPU:compressWithDict(base64Data) end

---Decompress data from dictionary references.
---@param hashMap table Dictionary hash map
---@return string decompressed Decompressed data
function DirectGPU:decompressFromDict(hashMap) end

---Get a chunk from the dictionary.
---@param hash number The chunk hash
---@return string chunk The chunk data
---@nodiscard
function DirectGPU:getChunk(hash) end

---Get dictionary statistics.
---@return string stats JSON stats
---@nodiscard
function DirectGPU:getDictionaryStats() end

---Check if a chunk exists in the dictionary.
---@param hash number The chunk hash
---@return boolean exists
---@nodiscard
function DirectGPU:hasChunk(hash) end

-- endregion

-- ============================================================================
-- region 3D Camera
-- ============================================================================

---Clear the depth buffer.
---@param displayId number
function DirectGPU:clearZBuffer(displayId) end

---Get camera information.
---@param displayId number
---@return string info JSON camera info
---@nodiscard
function DirectGPU:getCameraInfo(displayId) end

---Point the camera at a target position.
---@param displayId number
---@param targetX number
---@param targetY number
---@param targetZ number
function DirectGPU:lookAt(displayId, targetX, targetY, targetZ) end

---Set the camera position.
---@param displayId number
---@param x number
---@param y number
---@param z number
function DirectGPU:setCameraPosition(displayId, x, y, z) end

---Set the camera rotation.
---@param displayId number
---@param pitch number
---@param yaw number
---@param roll number
function DirectGPU:setCameraRotation(displayId, pitch, yaw, roll) end

---Set the camera look-at target.
---@param displayId number
---@param x number
---@param y number
---@param z number
function DirectGPU:setCameraTarget(displayId, x, y, z) end

---Setup the 3D camera projection.
---@param displayId number
---@param fov number Field of view in degrees
---@param near number Near clipping plane
---@param far number Far clipping plane
---@return string info Camera setup info
function DirectGPU:setupCamera(displayId, fov, near, far) end

-- endregion

-- ============================================================================
-- region 3D Primitives
-- ============================================================================

---Clear all 3D objects from the display.
---@param displayId number
function DirectGPU:clear3D(displayId) end

---Draw a 3D cube.
---@param displayId number
---@param x number Position X
---@param y number Position Y
---@param z number Position Z
---@param size number Cube size
---@param rotX number Rotation X degrees
---@param rotY number Rotation Y degrees
---@param rotZ number Rotation Z degrees
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:drawCube(displayId, x, y, z, size, rotX, rotY, rotZ, r, g, b) end

---Draw a 3D pyramid.
---@param displayId number
---@param x number
---@param y number
---@param z number
---@param size number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param r number
---@param g number
---@param b number
function DirectGPU:drawPyramid(displayId, x, y, z, size, rotX, rotY, rotZ, r, g, b) end

---Draw a 3D sphere.
---@param displayId number
---@param x number
---@param y number
---@param z number
---@param radius number
---@param segments number Subdivision level
---@param r number
---@param g number
---@param b number
---@param textureNameObj? any Optional texture
function DirectGPU:drawSphere(displayId, x, y, z, radius, segments, r, g, b, textureNameObj) end

-- endregion

-- ============================================================================
-- region 3D Models
-- ============================================================================

---Clear all loaded 3D models.
function DirectGPU:clearAll3DModels() end

---Draw a loaded 3D model.
---@param displayId number
---@param modelId number
---@param x number
---@param y number
---@param z number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param scale number
---@param r number
---@param g number
---@param b number
function DirectGPU:draw3DModel(displayId, modelId, x, y, z, rotX, rotY, rotZ, scale, r, g, b) end

---Draw a textured 3D model.
---@param displayId number
---@param modelId number
---@param x number
---@param y number
---@param z number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param scale number
---@param textureId number
function DirectGPU:draw3DModelTextured(displayId, modelId, x, y, z, rotX, rotY, rotZ, scale, textureId) end

---Get info about a loaded 3D model.
---@param modelId number
---@return string info JSON model info
---@nodiscard
function DirectGPU:get3DModelInfo(modelId) end

---Load a 3D model from OBJ string data.
---@param objData string OBJ format model data
---@return number modelId
function DirectGPU:load3DModel(objData) end

---Load a 3D model from base64 OBJ data.
---@param base64ObjData string
---@return number modelId
function DirectGPU:load3DModelFromBytes(base64ObjData) end

---Unload a 3D model.
---@param modelId number
---@return boolean success
function DirectGPU:unload3DModel(modelId) end

-- endregion

-- ============================================================================
-- region 3D Lighting
-- ============================================================================

---Add an ambient light.
---@param displayId number
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param intensity number Light intensity
function DirectGPU:addAmbientLight(displayId, r, g, b, intensity) end

---Add a directional light.
---@param displayId number
---@param dirX number Direction X
---@param dirY number Direction Y
---@param dirZ number Direction Z
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param intensity number Light intensity
function DirectGPU:addDirectionalLight(displayId, dirX, dirY, dirZ, r, g, b, intensity) end

---Clear all lights from a display.
---@param displayId number
function DirectGPU:clearLights(displayId) end

---Enable or disable backface culling.
---@param displayId number
---@param enabled boolean
function DirectGPU:setBackfaceCulling(displayId, enabled) end

---Enable or disable Phong shading.
---@param displayId number
---@param enabled boolean
function DirectGPU:setPhongShading(displayId, enabled) end

-- endregion

-- ============================================================================
-- region Textures
-- ============================================================================

---Get info about a loaded texture.
---@param textureId number
---@return string info JSON texture info
---@nodiscard
function DirectGPU:getTextureInfo(textureId) end

---Load a texture from raw pixel data.
---@param width number
---@param height number
---@param base64PixelData string Base64-encoded RGB pixel data
---@return number textureId
function DirectGPU:loadTexture(width, height, base64PixelData) end

---Load a texture from image data.
---@param imageData any Image data table
---@return number textureId
function DirectGPU:loadTextureFromImage(imageData) end

---Unload a texture.
---@param textureId number
---@return boolean success
function DirectGPU:unloadTexture(textureId) end

-- endregion

-- ============================================================================
-- region Input Events
-- ============================================================================

---Clear all pending events for a display.
---@param displayId number
function DirectGPU:clearEvents(displayId) end

---Check if there are pending events.
---@param displayId number
---@return boolean hasEvents
---@nodiscard
function DirectGPU:hasEvents(displayId) end

---Poll the next event. Returns nil-like if no events.
---Event types: "mouse_click", "mouse_drag", "mouse_up", "mouse_scroll"
---Event fields: type, button, x, y
---@param displayId number
---@return string event JSON event data
function DirectGPU:pollEvent(displayId) end

-- endregion

-- ============================================================================
-- region World Data
-- ============================================================================

---Get the biome at a world position.
---@param x number
---@param y number
---@param z number
---@return string biome The biome name
---@nodiscard
function DirectGPU:getBiomeAt(x, y, z) end

---Get the current dimension.
---@return string dimension e.g. "minecraft:overworld"
---@nodiscard
function DirectGPU:getDimension() end

---Get moon phase information.
---@return string moonInfo JSON moon info
---@nodiscard
function DirectGPU:getMoonInfo() end

---Get time information.
---@return string timeInfo JSON time info
---@nodiscard
function DirectGPU:getTimeInfo() end

---Get the current weather.
---@return string weather JSON weather info
---@nodiscard
function DirectGPU:getWeather() end

---Get world information.
---@return string worldInfo JSON world info
---@nodiscard
function DirectGPU:getWorldInfo() end

-- endregion

-- ============================================================================
-- region Controller Input
-- ============================================================================

---Clear controller events.
---@param controllerId number
function DirectGPU:clearControllerEvents(controllerId) end

---Get all axis values for a controller.
---@param controllerId number
---@return table axes Array of axis values
---@nodiscard
function DirectGPU:getAxes(controllerId) end

---Get a specific axis value.
---@param controllerId number
---@param axisIndex number
---@return number value Axis value (-1.0 to 1.0)
---@nodiscard
function DirectGPU:getAxis(controllerId, axisIndex) end

---Get a specific button state.
---@param controllerId number
---@param buttonIndex number
---@return boolean pressed
---@nodiscard
function DirectGPU:getButton(controllerId, buttonIndex) end

---Get all button states.
---@param controllerId number
---@return table buttons Array of button states
---@nodiscard
function DirectGPU:getButtons(controllerId) end

---Get the number of connected controllers.
---@return number count
---@nodiscard
function DirectGPU:getControllerCount() end

---Get the current deadzone threshold.
---@return number deadzone
---@nodiscard
function DirectGPU:getControllerDeadzone() end

---Get info about a controller.
---@param controllerId number
---@return string info JSON controller info
---@nodiscard
function DirectGPU:getControllerInfo(controllerId) end

---Check for pending controller events.
---@param controllerId number
---@return boolean hasEvents
---@nodiscard
function DirectGPU:hasControllerEvents(controllerId) end

---Poll the next controller event.
---@param controllerId number
---@return string event JSON event data
function DirectGPU:pollControllerEvent(controllerId) end

---Scan for connected controllers.
function DirectGPU:scanForControllers() end

---Set the deadzone threshold.
---@param deadzone number
function DirectGPU:setControllerDeadzone(deadzone) end

---Update controller state (call before reading).
---@param controllerId number
function DirectGPU:updateControllerState(controllerId) end

-- endregion

-- ============================================================================
-- region Controller Mapping
-- ============================================================================

---Export raw controller state for debugging.
---@param controllerId number
---@return string state JSON raw state
---@nodiscard
function DirectGPU:exportRawControllerState(controllerId) end

---Get the current button/axis mapping.
---@param controllerId number
---@return string mapping JSON mapping
---@nodiscard
function DirectGPU:getControllerMapping(controllerId) end

---Get a mapped axis value by name.
---@param controllerId number
---@param axisName string
---@return number value
---@nodiscard
function DirectGPU:getMappedAxis(controllerId, axisName) end

---Get a mapped button state by name.
---@param controllerId number
---@param buttonName string
---@return boolean pressed
---@nodiscard
function DirectGPU:getMappedButton(controllerId, buttonName) end

---Reset controller mapping to defaults.
---@param controllerId number
function DirectGPU:resetControllerMapping(controllerId) end

---Save all controller mappings.
function DirectGPU:saveControllerMappings() end

---Map a named axis to a raw axis.
---@param controllerId number
---@param axisName string
---@param rawAxis number
---@param inverted boolean
function DirectGPU:setAxisMapping(controllerId, axisName, rawAxis, inverted) end

---Map a named button to a raw button.
---@param controllerId number
---@param buttonName string
---@param rawButton number
function DirectGPU:setButtonMapping(controllerId, buttonName, rawButton) end

-- endregion

-- ============================================================================
-- region Controller Profiles
-- ============================================================================

---Get axis names for a controller profile.
---@param controllerId number
---@return string axisNames JSON array of names
---@nodiscard
function DirectGPU:getControllerAxisNames(controllerId) end

---Get button names for a controller profile.
---@param controllerId number
---@return string buttonNames JSON array of names
---@nodiscard
function DirectGPU:getControllerButtonNames(controllerId) end

---Get all available inputs for a controller.
---@param controllerId number
---@return table inputs
---@nodiscard
function DirectGPU:getControllerInputs(controllerId) end

---Get the controller's profile.
---@param controllerId number
---@return string profile JSON profile
---@nodiscard
function DirectGPU:getControllerProfile(controllerId) end

---Get the controller type.
---@param controllerId number
---@return string controllerType
---@nodiscard
function DirectGPU:getControllerType(controllerId) end

---Get named axes that are currently active (above threshold).
---@param controllerId number
---@param threshold number
---@return string activeAxes JSON active axes
---@nodiscard
function DirectGPU:getNamedAxesActive(controllerId, threshold) end

---Get a named axis value.
---@param controllerId number
---@param axisName string e.g. "LEFT_STICK_X", "RIGHT_TRIGGER"
---@return number value
---@nodiscard
function DirectGPU:getNamedAxis(controllerId, axisName) end

---Get a named button state.
---@param controllerId number
---@param buttonName string e.g. "A", "B", "X", "Y", "START"
---@return boolean pressed
---@nodiscard
function DirectGPU:getNamedButton(controllerId, buttonName) end

---Get all currently pressed named buttons.
---@param controllerId number
---@return string pressedButtons JSON array
---@nodiscard
function DirectGPU:getNamedButtonsPressed(controllerId) end

---Check if a controller has a specific named input.
---@param controllerId number
---@param inputName string
---@return boolean hasInput
---@nodiscard
function DirectGPU:hasInput(controllerId, inputName) end

---Refresh a controller's profile.
---@param controllerId number
function DirectGPU:refreshControllerProfile(controllerId) end

-- endregion

-- ============================================================================
-- region Server-Side Controllers
-- ============================================================================

---Get the player's UUID.
---@return string uuid
---@nodiscard
function DirectGPU:getPlayerUUID() end

---Get server-side controller axes.
---@param playerUUID string
---@param localControllerId number
---@return table axes
---@nodiscard
function DirectGPU:getServerControllerAxes(playerUUID, localControllerId) end

---Get a server-side controller axis.
---@param playerUUID string
---@param controllerId number
---@param axisIndex number
---@return number value
---@nodiscard
function DirectGPU:getServerControllerAxis(playerUUID, controllerId, axisIndex) end

---Get a server-side controller button.
---@param playerUUID string
---@param controllerId number
---@param buttonIndex number
---@return boolean pressed
---@nodiscard
function DirectGPU:getServerControllerButton(playerUUID, controllerId, buttonIndex) end

---Get server-side controller buttons.
---@param playerUUID string
---@param localControllerId number
---@return table buttons
---@nodiscard
function DirectGPU:getServerControllerButtons(playerUUID, localControllerId) end

---Get server-side controller count for a player.
---@param playerUUID string
---@return number count
---@nodiscard
function DirectGPU:getServerControllerCount(playerUUID) end

---Get server-side controller info.
---@param playerUUID string
---@param localControllerId number
---@return string info JSON
---@nodiscard
function DirectGPU:getServerControllerInfo(playerUUID, localControllerId) end

---Get full server-side controller state.
---@param playerUUID string
---@param controllerId number
---@return string state JSON
---@nodiscard
function DirectGPU:getServerControllerState(playerUUID, controllerId) end

---Check if a player has a server-side controller.
---@param playerUUID string
---@param localControllerId number
---@return boolean hasController
---@nodiscard
function DirectGPU:hasServerController(playerUUID, localControllerId) end

-- endregion

-- ============================================================================
-- region Vector Graphics
-- ============================================================================

---Draw a bezier curve.
---@param displayId number
---@param pointsObj table Control points
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param segmentsObj? any Segment count
function DirectGPU:drawBezierCurve(displayId, pointsObj, r, g, b, segmentsObj) end

---Draw a rounded rectangle.
---@param displayId number
---@param x number
---@param y number
---@param w number
---@param h number
---@param radius number Corner radius
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param filled boolean
function DirectGPU:drawRoundedRect(displayId, x, y, w, h, radius, r, g, b, filled) end

---Draw an SVG path.
---@param displayId number
---@param pathData string SVG path data string
---@param x number Offset X
---@param y number Offset Y
---@param scale number Scale factor
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:drawSVGPath(displayId, pathData, x, y, scale, r, g, b) end

---Draw a star shape.
---@param displayId number
---@param cx number Center X
---@param cy number Center Y
---@param points number Number of points
---@param outerRadius number
---@param innerRadius number
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param filled boolean
function DirectGPU:drawStar(displayId, cx, cy, points, outerRadius, innerRadius, r, g, b, filled) end

-- endregion

-- ============================================================================
-- region Metaballs
-- ============================================================================

---Add a metaball to a system.
---@param systemId number
---@param x number
---@param y number
---@param radius number
---@param strength number
---@return number ballId
function DirectGPU:addMetaball(systemId, x, y, radius, strength) end

---Clear all metaballs in a system.
---@param systemId number
function DirectGPU:clearMetaballs(systemId) end

---Create a metaball system on a display.
---@param displayId number
---@return number systemId
function DirectGPU:createMetaballSystem(displayId) end

---Get the number of metaballs in a system.
---@param systemId number
---@return number count
---@nodiscard
function DirectGPU:getMetaballCount(systemId) end

---Get info about a specific metaball.
---@param systemId number
---@param ballId number
---@return string info JSON
---@nodiscard
function DirectGPU:getMetaballInfo(systemId, ballId) end

---Remove a metaball system.
---@param systemId number
function DirectGPU:removeMetaballSystem(systemId) end

---Render the metaball system.
---@param systemId number
---@param threshold number Isosurface threshold
---@param renderMode number Rendering mode
function DirectGPU:renderMetaballs(systemId, threshold, renderMode) end

---Set a metaball's color.
---@param systemId number
---@param ballId number
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
function DirectGPU:setMetaballColor(systemId, ballId, r, g, b) end

---Enable physics simulation for a metaball system.
---@param systemId number
---@param enabled boolean
---@param gravity number
---@param drag number
function DirectGPU:setMetaballPhysics(systemId, enabled, gravity, drag) end

---Set a metaball's velocity.
---@param systemId number
---@param ballId number
---@param vx number
---@param vy number
function DirectGPU:setMetaballVelocity(systemId, ballId, vx, vy) end

---Update metaball physics simulation.
---@param systemId number
---@param deltaTime number Time step
function DirectGPU:updateMetaballs(systemId, deltaTime) end

-- endregion

-- ============================================================================
-- region Calibration
-- ============================================================================

---Get calibration values.
---@return string values JSON calibration values
---@nodiscard
function DirectGPU:getCalibrationValues() end

---Enable/disable calibration mode.
---@param enabled boolean
---@param divisor number
---@param subtract number
function DirectGPU:setCalibrationMode(enabled, divisor, subtract) end

-- endregion
```

- [ ] **Step 2: Create types/direct-gpu/map-reader.lua**

```lua
---@meta

---The Map Reader peripheral from DirectGPU.
---Reads Minecraft maps from its internal 9-slot inventory.
---Peripheral type: "map_reader"
---@class MapReader
local MapReader = {}

---Scan all map items in the internal inventory.
---@return table[] maps Array of {mapId: number, slot: number, displayName: string, stackSize: number}
---@nodiscard
function MapReader:scanAll() end

---Alias for scanAll().
---@return table[] maps
---@nodiscard
function MapReader:scanInternal() end

---Returns empty list (adjacent scanning not supported).
---@return table[] empty Always empty
---@nodiscard
function MapReader:scanAdjacent() end

---Get counts of detected maps.
---@return {internal: number, adjacent: number, total: number} counts
---@nodiscard
function MapReader:getMapCounts() end

---Returns empty list (no adjacent containers supported).
---@return table[] empty Always empty
---@nodiscard
function MapReader:getAdjacentContainers() end

---Read a map by its map ID.
---@param mapId number The map ID (not slot number)
---@return {scale: number, dimension: string, centerX: number, centerZ: number, locked: boolean, pixels: string, decorations: table[]} mapData
---@nodiscard
function MapReader:readMap(mapId) end
```

- [ ] **Step 3: Verify and commit**

```bash
wc -l types/direct-gpu/gpu.lua types/direct-gpu/map-reader.lua
```

```bash
git add types/direct-gpu/
git commit -m "feat: CC: Direct GPU type stubs — all 130+ functions + map reader"
```

---

## Task 9: Basalt Type Stubs

**Files:**
- Create: `types/basalt/basalt.lua`

Basalt 2 ships a `BasaltLS.lua` file (5861 lines) with auto-generated LuaLS annotations. We download it directly.

- [ ] **Step 1: Download BasaltLS.lua from the Basalt2 repo**

```bash
mkdir -p types/basalt
curl -sL "https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/BasaltLS.lua" -o types/basalt/basalt.lua
```

- [ ] **Step 2: Verify download**

```bash
head -5 types/basalt/basalt.lua
wc -l types/basalt/basalt.lua
```

Expected: first line is `---@meta`, total ~5861 lines.

- [ ] **Step 3: Commit**

```bash
git add types/basalt/
git commit -m "feat: Basalt 2 type stubs — downloaded from Pyroxenium/Basalt2"
```

---

## Task 10: Shared Libraries

**Files:**
- Create: `lib/log.lua`
- Create: `lib/event.lua`
- Create: `lib/net.lua`

- [ ] **Step 1: Create lib/log.lua**

```lua
local log = {}

local _file = nil
local _monitor = nil
local _level_names = { "INFO", "WARN", "ERROR" }

local function _timestamp()
    local ms = os.epoch("utc")
    local s = math.floor(ms / 1000)
    local rem = ms % 1000
    return string.format("%d.%03d", s, rem)
end

local function _write(level, msg, ...)
    local text = string.format("[%s] [%s] %s", _timestamp(), _level_names[level], string.format(msg, ...))
    if _file then
        _file.write(text .. "\n")
        _file.flush()
    end
    if _monitor then
        local _, h = _monitor.getSize()
        _monitor.scroll(1)
        _monitor.setCursorPos(1, h)
        _monitor.write(text)
    end
end

function log.init(path)
    if _file then _file.close() end
    _file = fs.open(path or "/log.txt", "a")
end

function log.toMonitor(side)
    local m = peripheral.wrap(side)
    if m then
        _monitor = m
        _monitor.setTextScale(0.5)
        _monitor.clear()
        _monitor.setCursorPos(1, 1)
    end
end

function log.info(msg, ...)  _write(1, msg, ...) end
function log.warn(msg, ...)  _write(2, msg, ...) end
function log.error(msg, ...) _write(3, msg, ...) end

function log.close()
    if _file then _file.close() end
    _file = nil
    _monitor = nil
end

return log
```

- [ ] **Step 2: Create lib/event.lua**

```lua
local event = {}

local _handlers = {}
local _timers = {}
local _running = false

function event.on(eventName, callback)
    if not _handlers[eventName] then
        _handlers[eventName] = {}
    end
    table.insert(_handlers[eventName], callback)
end

function event.every(seconds, callback)
    local id = os.startTimer(seconds)
    _timers[id] = { interval = seconds, callback = callback }
end

function event.run()
    _running = true
    while _running do
        local e = { os.pullEvent() }
        local name = e[1]

        if name == "timer" then
            local id = e[2]
            local t = _timers[id]
            if t then
                _timers[id] = nil
                t.callback()
                if _running then
                    local newId = os.startTimer(t.interval)
                    _timers[newId] = t
                end
            end
        end

        local handlers = _handlers[name]
        if handlers then
            for _, cb in ipairs(handlers) do
                cb(unpack(e, 2))
            end
        end

        local allHandlers = _handlers["*"]
        if allHandlers then
            for _, cb in ipairs(allHandlers) do
                cb(unpack(e))
            end
        end
    end
end

function event.stop()
    _running = false
end

return event
```

- [ ] **Step 3: Create lib/net.lua**

```lua
local net = {}

local RPC_TIMEOUT = 5

local function _serialize(data)
    return textutils.serialize(data)
end

local function _unserialize(data)
    if type(data) == "string" then
        return textutils.unserialize(data)
    end
    return data
end

function net.open(side)
    if side then
        rednet.open(side)
    else
        local modem = peripheral.find("modem")
        if modem then
            rednet.open(peripheral.getName(modem))
        else
            error("No modem found", 2)
        end
    end
end

function net.send(recipient, protocol, data)
    return rednet.send(recipient, _serialize(data), protocol)
end

function net.broadcast(protocol, data)
    rednet.broadcast(_serialize(data), protocol)
end

function net.receive(protocol, timeout)
    local sender, raw, proto = rednet.receive(protocol, timeout)
    if sender then
        return sender, _unserialize(raw), proto
    end
    return nil, nil, nil
end

function net.rpc(recipient, method, args, timeout)
    local msg = { type = "rpc_request", method = method, args = args or {} }
    net.send(recipient, "rpc", msg)
    local sender, response = net.receive("rpc", timeout or RPC_TIMEOUT)
    if not sender then
        return nil, "timeout"
    end
    if response and response.type == "rpc_response" then
        if response.error then
            return nil, response.error
        end
        return response.result
    end
    return nil, "invalid response"
end

function net.serve(protocol, handlers)
    while true do
        local sender, msg = net.receive(protocol)
        if sender and msg then
            if msg.type == "rpc_request" and msg.method then
                local handler = handlers[msg.method]
                local response
                if handler then
                    local ok, result = pcall(handler, sender, unpack(msg.args or {}))
                    if ok then
                        response = { type = "rpc_response", result = result }
                    else
                        response = { type = "rpc_response", error = result }
                    end
                else
                    response = { type = "rpc_response", error = "unknown method: " .. msg.method }
                end
                net.send(sender, protocol, response)
            elseif handlers["*"] then
                handlers["*"](sender, msg)
            end
        end
    end
end

return net
```

- [ ] **Step 4: Verify all libs**

```bash
ls -la lib/log.lua lib/event.lua lib/net.lua
```

- [ ] **Step 5: Commit**

```bash
git add lib/
git commit -m "feat: shared libraries — log, event, net"
```

---

## Task 11: Scripts — Config and Templates

**Files:**
- Create: `scripts/config.sh`
- Create: `scripts/templates/CLAUDE.md.template`
- Create: `scripts/templates/startup.lua.template`
- Create: `scripts/templates/main.lua.template`
- Create: `scripts/templates/install.lua.template`
- Create: `scripts/templates/deploy.sh.template`

- [ ] **Step 1: Create scripts/config.sh**

```bash
#!/bin/bash
GITHUB_USER="CHANGEME"
GITHUB_REPO="FriendsCC"
GITHUB_BRANCH="main"
REPO_RAW="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH"
```

- [ ] **Step 2: Create scripts/templates/CLAUDE.md.template**

```markdown
# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Addons
{{ADDON_REFS}}

## Libs
{{LIB_REFS}}

## Notes
<!-- Add project-specific context: hardware layout, computer IDs, network protocols -->
```

- [ ] **Step 3: Create scripts/templates/startup.lua.template**

```lua
package.path = package.path .. ";/lib/?.lua;/lib/?/init.lua"
shell.run("main.lua")
```

- [ ] **Step 4: Create scripts/templates/main.lua.template**

```lua
{{REQUIRES}}

-- Your code here
{{BASALT_RUN}}
```

- [ ] **Step 5: Create scripts/templates/install.lua.template**

```lua
local repo = "{{REPO_RAW}}"

local files = {
{{FILE_LIST}}
}

for _, f in ipairs(files) do
    local dir = fs.getDir(f.path)
    if dir ~= "" and not fs.exists(dir) then
        fs.makeDir(dir)
    end
    if fs.exists(f.path) then
        fs.delete(f.path)
    end
    print("Downloading " .. f.path)
    shell.run("wget", repo .. "/" .. f.remote, f.path)
end

{{BASALT_INSTALL}}

print("Done! Run 'reboot' to start.")
```

- [ ] **Step 6: Create scripts/templates/deploy.sh.template**

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/config.sh"

echo "-- Paste these commands into the CC:Tweaked computer:"
echo ""
{{WGET_COMMANDS}}
echo ""
echo "-- Then reboot the computer."
```

- [ ] **Step 7: Verify and commit**

```bash
ls scripts/config.sh scripts/templates/
```

```bash
git add scripts/config.sh scripts/templates/
git commit -m "feat: deploy config and scaffolding templates"
```

---

## Task 12: Scaffolding Script

**Files:**
- Create: `scripts/new-project.sh`

- [ ] **Step 1: Create scripts/new-project.sh**

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

source "$SCRIPT_DIR/config.sh"

# --- Prompts ---

read -rp "Project name (kebab-case): " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: project name required"
    exit 1
fi

if [[ -d "$ROOT_DIR/projects/$PROJECT_NAME" ]]; then
    echo "Error: projects/$PROJECT_NAME already exists"
    exit 1
fi

read -rp "Description: " DESCRIPTION

echo ""
echo "Select addons (y/n for each):"
read -rp "  CC:Sable? [y/N] " USE_SABLE
read -rp "  CC:C Bridge? [y/N] " USE_CCCBRIDGE
read -rp "  CC: Direct GPU? [y/N] " USE_DIRECTGPU
read -rp "  Basalt (UI)? [y/N] " USE_BASALT

echo ""
echo "Select shared libs (y/n for each):"
read -rp "  net.lua? [y/N] " USE_NET
read -rp "  event.lua? [y/N] " USE_EVENT
read -rp "  log.lua? [y/N] " USE_LOG

# --- Build references ---

ADDON_REFS=""
LIB_REFS=""
REQUIRES=""
FILE_LIST=""
WGET_COMMANDS=""
BASALT_RUN=""
BASALT_INSTALL=""

if [[ "${USE_SABLE,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/cc-sable/aero.lua\n@types/cc-sable/sublevel.lua\n'
fi
if [[ "${USE_CCCBRIDGE,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/ccc-bridge/source.lua\n@types/ccc-bridge/red-router.lua\n@types/ccc-bridge/animatronic.lua\n@types/ccc-bridge/scroller-pane.lua\n'
fi
if [[ "${USE_DIRECTGPU,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/direct-gpu/gpu.lua\n@types/direct-gpu/map-reader.lua\n'
fi
if [[ "${USE_BASALT,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/basalt/basalt.lua\n'
    REQUIRES+=$'local basalt = require("basalt")\n'
    BASALT_RUN=$'\nbasalt.run()'
    BASALT_INSTALL='if not fs.exists("/basalt.lua") and not fs.exists("/basalt") then
    print("Installing Basalt...")
    shell.run("wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -r")
end'
fi

if [[ "${USE_NET,,}" == "y" ]]; then
    LIB_REFS+=$'@lib/net.lua\n'
    REQUIRES+=$'local net = require("net")\n'
    FILE_LIST+="    {remote = \"lib/net.lua\", path = \"/lib/net.lua\"},"$'\n'
    WGET_COMMANDS+="echo \"wget \$REPO_RAW/lib/net.lua /lib/net.lua\""$'\n'
fi
if [[ "${USE_EVENT,,}" == "y" ]]; then
    LIB_REFS+=$'@lib/event.lua\n'
    REQUIRES+=$'local event = require("event")\n'
    FILE_LIST+="    {remote = \"lib/event.lua\", path = \"/lib/event.lua\"},"$'\n'
    WGET_COMMANDS+="echo \"wget \$REPO_RAW/lib/event.lua /lib/event.lua\""$'\n'
fi
if [[ "${USE_LOG,,}" == "y" ]]; then
    LIB_REFS+=$'@lib/log.lua\n'
    REQUIRES+=$'local log = require("log")\n'
    FILE_LIST+="    {remote = \"lib/log.lua\", path = \"/lib/log.lua\"},"$'\n'
    WGET_COMMANDS+="echo \"wget \$REPO_RAW/lib/log.lua /lib/log.lua\""$'\n'
fi

# Add project files to deploy lists
FILE_LIST+="    {remote = \"projects/$PROJECT_NAME/startup.lua\", path = \"/startup.lua\"},"$'\n'
FILE_LIST+="    {remote = \"projects/$PROJECT_NAME/main.lua\", path = \"/main.lua\"},"$'\n'
WGET_COMMANDS+="echo \"wget \$REPO_RAW/projects/$PROJECT_NAME/startup.lua /startup.lua\""$'\n'
WGET_COMMANDS+="echo \"wget \$REPO_RAW/projects/$PROJECT_NAME/main.lua /main.lua\""$'\n'

if [[ "${USE_BASALT,,}" == "y" ]]; then
    WGET_COMMANDS+="echo \"wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -r\""$'\n'
fi

# --- Generate files ---

PROJECT_DIR="$ROOT_DIR/projects/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"

# CLAUDE.md
sed -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{DESCRIPTION}}|$DESCRIPTION|g" \
    "$TEMPLATES_DIR/CLAUDE.md.template" > "$PROJECT_DIR/CLAUDE.md.tmp"

# Replace multiline placeholders
{
    while IFS= read -r line; do
        case "$line" in
            *"{{ADDON_REFS}}"*)
                printf "%s" "$ADDON_REFS"
                ;;
            *"{{LIB_REFS}}"*)
                printf "%s" "$LIB_REFS"
                ;;
            *)
                printf "%s\n" "$line"
                ;;
        esac
    done
} < "$PROJECT_DIR/CLAUDE.md.tmp" > "$PROJECT_DIR/CLAUDE.md"
rm "$PROJECT_DIR/CLAUDE.md.tmp"

# startup.lua
cp "$TEMPLATES_DIR/startup.lua.template" "$PROJECT_DIR/startup.lua"

# main.lua
{
    printf "%s" "$REQUIRES"
    printf "\n-- Your code here\n"
    if [[ -n "$BASALT_RUN" ]]; then
        printf "%s\n" "$BASALT_RUN"
    fi
} > "$PROJECT_DIR/main.lua"

# install.lua
sed -e "s|{{REPO_RAW}}|$REPO_RAW|g" \
    "$TEMPLATES_DIR/install.lua.template" > "$PROJECT_DIR/install.lua.tmp"
{
    while IFS= read -r line; do
        case "$line" in
            *"{{FILE_LIST}}"*)
                printf "%s" "$FILE_LIST"
                ;;
            *"{{BASALT_INSTALL}}"*)
                printf "%s\n" "$BASALT_INSTALL"
                ;;
            *)
                printf "%s\n" "$line"
                ;;
        esac
    done
} < "$PROJECT_DIR/install.lua.tmp" > "$PROJECT_DIR/install.lua"
rm "$PROJECT_DIR/install.lua.tmp"

# deploy.sh
{
    while IFS= read -r line; do
        case "$line" in
            *"{{WGET_COMMANDS}}"*)
                printf "%s" "$WGET_COMMANDS"
                ;;
            *)
                printf "%s\n" "$line"
                ;;
        esac
    done
} < "$TEMPLATES_DIR/deploy.sh.template" > "$PROJECT_DIR/deploy.sh"
chmod +x "$PROJECT_DIR/deploy.sh"

echo ""
echo "Created projects/$PROJECT_NAME/"
echo "  CLAUDE.md"
echo "  startup.lua"
echo "  main.lua"
echo "  install.lua"
echo "  deploy.sh"
echo ""
echo "Next: cd projects/$PROJECT_NAME and start coding!"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/new-project.sh
```

- [ ] **Step 3: Test the scaffolding by creating example project**

```bash
cd /home/marlon/Code/Lua/FriendsCC
echo -e "example\nA demo project showing basic CC:Tweaked patterns\ny\nn\nn\ny\ny\nn\ny" | bash scripts/new-project.sh
```

Expected: creates `projects/example/` with CLAUDE.md, startup.lua, main.lua, install.lua, deploy.sh.

- [ ] **Step 4: Verify generated files**

```bash
cat projects/example/CLAUDE.md
cat projects/example/main.lua
cat projects/example/install.lua
```

Verify:
- CLAUDE.md has CC:Sable `@types/` references and Basalt reference
- main.lua has `require("basalt")`, `require("net")`, `require("log")`, and `basalt.run()`
- install.lua has correct repo URL and file list

- [ ] **Step 5: Commit**

```bash
git add scripts/new-project.sh projects/example/
git commit -m "feat: scaffolding script and example project"
```

---

## Task 13: Final Verification

- [ ] **Step 1: Verify complete file structure**

```bash
find /home/marlon/Code/Lua/FriendsCC -type f | sort | grep -v '.git/' | grep -v 'docs/superpowers'
```

Expected output should match the spec's repository structure with all files present.

- [ ] **Step 2: Verify git log**

```bash
git log --oneline
```

Expected: 8+ commits covering foundation, all type stubs, shared libs, templates, scaffolding, example project.

- [ ] **Step 3: Verify .luarc.json points to all type dirs**

```bash
cat .luarc.json
```

Verify all 5 type directories are listed in workspace.library.

- [ ] **Step 4: Verify CLAUDE.md @-references exist**

```bash
grep "^@" CLAUDE.md | while read -r ref; do
    file="${ref#@}"
    if [ ! -f "$file" ]; then
        echo "MISSING: $file"
    fi
done
```

Expected: no MISSING output — every `@`-referenced file in CLAUDE.md should exist.

- [ ] **Step 5: Final commit if any fixes needed**

If any issues were found and fixed:

```bash
git add -A
git commit -m "fix: address verification issues"
```
