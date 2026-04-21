---@meta

---@class multishellAPI
multishell = {}

---@return number
---@nodiscard
function multishell.getCurrent() end

---@return number
---@nodiscard
function multishell.getCount() end

---@param env table
---@param path string
---@param ... string
---@return number id
function multishell.launch(env, path, ...) end

---@param id number
---@param title string
function multishell.setTitle(id, title) end

---@param id number
---@return string|nil
---@nodiscard
function multishell.getTitle(id) end

---@param id number
---@return boolean
function multishell.setFocus(id) end

---@return number
---@nodiscard
function multishell.getFocus() end
