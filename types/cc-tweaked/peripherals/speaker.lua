---@meta

---@class Speaker
local Speaker = {}

---Yields.
---@param instrument string
---@param volume? number 0.0-3.0
---@param pitch? number 0-24
---@return boolean success
function Speaker:playNote(instrument, volume, pitch) end

---Yields.
---@param name string e.g. "minecraft:entity.pig.ambient"
---@param volume? number 0.0-3.0
---@param pitch? number 0.0-2.0
---@return boolean success
function Speaker:playSound(name, volume, pitch) end

---Yields.
---@param data number[] 8-bit signed PCM samples
---@param volume? number 0.0-3.0
---@return boolean success
function Speaker:playAudio(data, volume) end

function Speaker:stop() end
