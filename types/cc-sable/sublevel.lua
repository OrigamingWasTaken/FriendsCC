---@meta

---Sub-Level API for Create: Aeronautics contraptions.
---Only available on computers physically on a Sub-Level.
---Also provides the quaternion API via CC: Advanced Math.
---@class sublevelAPI
sublevel = {}

---@return boolean
function sublevel.isInPlotGrid() end

---Errors if not on a Sub-Level.
---@return string uuid
---@nodiscard
function sublevel.getUniqueId() end

---Errors if not on a Sub-Level.
---@return string name
---@nodiscard
function sublevel.getName() end

---Errors if not on a Sub-Level.
---@param newName string
function sublevel.setName(newName) end

---Errors if not on a Sub-Level.
---@return {position: vector, orientation: quaternion, scale: vector, rotationPoint: vector}
function sublevel.getLogicalPose() end

---Errors if not on a Sub-Level.
---@return {position: vector, orientation: quaternion, scale: vector, rotationPoint: vector}
function sublevel.getLastPose() end

---@return vector velocity
function sublevel.getVelocity() end

---Errors if not on a Sub-Level.
---@return vector linearVelocity
function sublevel.getLinearVelocity() end

---Errors if not on a Sub-Level.
---@return vector angularVelocity
function sublevel.getAngularVelocity() end

---Errors if not on a Sub-Level.
---@return vector centerOfMass
function sublevel.getCenterOfMass() end

---Errors if not on a Sub-Level.
---@return number mass
function sublevel.getMass() end

---Errors if not on a Sub-Level.
---@return number inverseMass
function sublevel.getInverseMass() end

---Errors if not on a Sub-Level.
---@return table inertiaTensor 3x3 matrix
function sublevel.getInertiaTensor() end

---Errors if not on a Sub-Level.
---@return table inverseInertiaTensor 3x3 matrix
function sublevel.getInverseInertiaTensor() end
