---@meta

---@class rednetAPI
rednet = {}

---@param modem string
function rednet.open(modem) end

---@param modem? string
function rednet.close(modem) end

---@param modem? string
---@return boolean
---@nodiscard
function rednet.isOpen(modem) end

---@param recipient number
---@param message any
---@param protocol? string
---@return boolean success
function rednet.send(recipient, message, protocol) end

---@param message any
---@param protocol? string
function rednet.broadcast(message, protocol) end

---Yields.
---@param protocolFilter? string
---@param timeout? number
---@return number|nil senderID
---@return any message
---@return string|nil protocol
function rednet.receive(protocolFilter, timeout) end

---@param protocol string
---@param hostname string
function rednet.host(protocol, hostname) end

---@param protocol string
function rednet.unhost(protocol) end

---Yields.
---@param protocol string
---@param hostname? string
---@return number|nil ...
function rednet.lookup(protocol, hostname) end
