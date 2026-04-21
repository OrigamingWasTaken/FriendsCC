---@meta

---@class diskAPI
disk = {}

---@param name string
---@return boolean
---@nodiscard
function disk.isPresent(name) end

---@param name string
---@return string|nil
---@nodiscard
function disk.getLabel(name) end

---@param name string
---@param label? string
function disk.setLabel(name, label) end

---@param name string
---@return boolean
---@nodiscard
function disk.hasData(name) end

---@param name string
---@return string|nil
---@nodiscard
function disk.getMountPath(name) end

---@param name string
---@return boolean
---@nodiscard
function disk.hasAudio(name) end

---@param name string
---@return string|nil|false
---@nodiscard
function disk.getAudioTitle(name) end

---@param name string
function disk.playAudio(name) end

---@param name string
function disk.stopAudio(name) end

---@param name string
function disk.eject(name) end

---@param name string
---@return number|nil
---@nodiscard
function disk.getID(name) end
