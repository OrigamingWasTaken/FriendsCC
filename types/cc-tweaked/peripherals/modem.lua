---@meta

---@class Modem
local Modem = {}

---@param channel number 0-65535
function Modem:open(channel) end

---@param channel number
function Modem:close(channel) end

function Modem:closeAll() end

---@param channel number
---@return boolean
---@nodiscard
function Modem:isOpen(channel) end

---@param channel number
---@param replyChannel number
---@param payload any
function Modem:transmit(channel, replyChannel, payload) end

---@return boolean
---@nodiscard
function Modem:isWireless() end

---@return string|nil
---@nodiscard
function Modem:getNameLocal() end

---@return string[]
---@nodiscard
function Modem:getNamesRemote() end

---@param name string
---@return boolean
---@nodiscard
function Modem:isPresentRemote(name) end

---@param name string
---@return string|nil
---@nodiscard
function Modem:getTypeRemote(name) end

---@param name string
---@param type string
---@return boolean|nil
---@nodiscard
function Modem:hasTypeRemote(name, type) end

---@param name string
---@return string[]|nil
---@nodiscard
function Modem:getMethodsRemote(name) end

---@param remoteName string
---@param method string
---@param ... any
---@return any ...
function Modem:callRemote(remoteName, method, ...) end
