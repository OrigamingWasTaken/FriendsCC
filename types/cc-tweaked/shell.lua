---@meta

---@class shellAPI
shell = {}

---Yields.
---@param command string
---@param ... string
---@return boolean
function shell.run(command, ...) end

---Yields.
---@param command string
---@param ... string
---@return boolean
function shell.execute(command, ...) end

function shell.exit() end

---@return string
---@nodiscard
function shell.dir() end

---@param path string
function shell.setDir(path) end

---@return string
---@nodiscard
function shell.path() end

---@param path string
function shell.setPath(path) end

---@param path string
---@return string
---@nodiscard
function shell.resolve(path) end

---@param name string
---@return string|nil
---@nodiscard
function shell.resolveProgram(name) end

---@return table<string, string>
---@nodiscard
function shell.aliases() end

---@param alias string
---@param program string
function shell.setAlias(alias, program) end

---@param alias string
function shell.clearAlias(alias) end

---@param showHidden? boolean
---@return string[]
---@nodiscard
function shell.programs(showHidden) end

---@param line string
---@return string[]|nil
---@nodiscard
function shell.complete(line) end

---@param prefix string
---@return string[]
---@nodiscard
function shell.completeProgram(prefix) end

---@return string
---@nodiscard
function shell.getRunningProgram() end

---@param id number
function shell.switchTab(id) end

---@param command string
---@param ... string
---@return number tabID
function shell.openTab(command, ...) end
