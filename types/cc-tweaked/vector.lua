---@meta

---@class vector
---@field x number
---@field y number
---@field z number
---@operator add(vector): vector
---@operator sub(vector): vector
---@operator mul(number): vector
---@operator unm: vector
local vectorInstance = {}

---@param o vector
---@return vector
---@nodiscard
function vectorInstance:add(o) end

---@param o vector
---@return vector
---@nodiscard
function vectorInstance:sub(o) end

---@param factor number
---@return vector
---@nodiscard
function vectorInstance:mul(factor) end

---@param factor number
---@return vector
---@nodiscard
function vectorInstance:div(factor) end

---@return vector
---@nodiscard
function vectorInstance:unm() end

---@param o vector
---@return number
---@nodiscard
function vectorInstance:dot(o) end

---@param o vector
---@return vector
---@nodiscard
function vectorInstance:cross(o) end

---@return number
---@nodiscard
function vectorInstance:length() end

---@return vector
---@nodiscard
function vectorInstance:normalize() end

---@param tolerance? number
---@return vector
---@nodiscard
function vectorInstance:round(tolerance) end

---@return string
---@nodiscard
function vectorInstance:tostring() end

---@param x number
---@param y number
---@param z number
---@return vector
---@nodiscard
function vector.new(x, y, z) end
