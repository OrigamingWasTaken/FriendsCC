---@meta

---Animatronic peripheral from CC:C Bridge.
---Controls robot puppets with face expressions and limb rotations.
---Peripheral type: "animatronic"
---@class Animatronic
local Animatronic = {}

---@param face string "normal"|"happy"|"question"|"sad"
function Animatronic:setFace(face) end

---@param kind string "linear"|"none"|"rusty"
function Animatronic:setTransition(kind) end

---Apply stored rotations. Resets stored values to 0.
function Animatronic:push() end

---@param x number -180 to 180
---@param y number -180 to 180
---@param z number -180 to 180
function Animatronic:setHeadRot(x, y, z) end

---@param x number -360 to 360
---@param y number -180 to 180
---@param z number -180 to 180
function Animatronic:setBodyRot(x, y, z) end

---@param x number -180 to 180
---@param y number -180 to 180
---@param z number -180 to 180
function Animatronic:setLeftArmRot(x, y, z) end

---@param x number -180 to 180
---@param y number -180 to 180
---@param z number -180 to 180
function Animatronic:setRightArmRot(x, y, z) end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredHeadRot() end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredBodyRot() end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredLeftArmRot() end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getStoredRightArmRot() end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedHeadRot() end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedBodyRot() end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedLeftArmRot() end

---@return number x, number y, number z
---@nodiscard
function Animatronic:getAppliedRightArmRot() end
