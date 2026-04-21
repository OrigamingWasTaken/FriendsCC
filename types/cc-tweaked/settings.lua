---@meta

---@class settingsAPI
settings = {}

---@param name string
---@param options? {description?: string, default?: any, type?: string}
function settings.define(name, options) end

---@param name string
function settings.undefine(name) end

---@param name string
---@param value any
function settings.set(name, value) end

---@param name string
---@param default? any
---@return any
function settings.get(name, default) end

---@param name string
function settings.unset(name) end

function settings.clear() end

---@return string[]
---@nodiscard
function settings.getNames() end

---@param name string
---@return {description?: string, default?: any, type?: string, value?: any}
---@nodiscard
function settings.getDetails(name) end

---@param path? string
---@return boolean
function settings.load(path) end

---@param path? string
---@return boolean
function settings.save(path) end
