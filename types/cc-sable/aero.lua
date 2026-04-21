---@meta

---Aerodynamics API from CC:Sable.
---Provides dimensional physics info from Sable.
---@class aeroAPI
aero = {}

---@param position vector
---@return number pressure
function aero.getAirPressure(position) end

---@return vector gravity
---@nodiscard
function aero.getGravity() end

---@return vector magneticNorth
---@nodiscard
function aero.getMagneticNorth() end

---@return number drag
---@nodiscard
function aero.getUniversalDrag() end

---@return {gravity?: vector, basePressure?: number, magneticNorth?: vector, universalDrag?: number}
---@nodiscard
function aero.getRaw() end

---@return {gravity?: vector, basePressure?: number, magneticNorth?: vector, universalDrag?: number}
---@nodiscard
function aero.getDefault() end

---@type aeroAPI
aerodynamics = aero
