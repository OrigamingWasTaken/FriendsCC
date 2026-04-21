---@meta

---@class peripheralAPI
peripheral = {}

---@return string[]
---@nodiscard
function peripheral.getNames() end

---@param name string
---@return boolean
---@nodiscard
function peripheral.isPresent(name) end

---@param peripheral string|table
---@return string ...
---@nodiscard
function peripheral.getType(peripheral) end

---@param peripheral string|table
---@param type string
---@return boolean|nil
---@nodiscard
function peripheral.hasType(peripheral, type) end

---@param name string
---@return string[]|nil
---@nodiscard
function peripheral.getMethods(name) end

---@param peripheral table
---@return string
---@nodiscard
function peripheral.getName(peripheral) end

---@param name string
---@param method string
---@param ... any
---@return any ...
function peripheral.call(name, method, ...) end

---@param name string
---@return table|nil
function peripheral.wrap(name) end

---@param type string
---@param filter? fun(name: string, wrapped: table): boolean
---@return table ...
function peripheral.find(type, filter) end
