---@meta

---Map Reader peripheral from DirectGPU.
---Reads Minecraft maps from its internal 9-slot inventory.
---Peripheral type: "map_reader"
---@class MapReader
local MapReader = {}

---@return table[] maps
---@nodiscard
function MapReader:scanAll() end

---@return table[] maps
---@nodiscard
function MapReader:scanInternal() end

---@return table[] empty Always empty
---@nodiscard
function MapReader:scanAdjacent() end

---@return {internal: number, adjacent: number, total: number}
---@nodiscard
function MapReader:getMapCounts() end

---@return table[] empty Always empty
---@nodiscard
function MapReader:getAdjacentContainers() end

---@param mapId number
---@return {scale: number, dimension: string, centerX: number, centerZ: number, locked: boolean, pixels: string, decorations: table[]}
---@nodiscard
function MapReader:readMap(mapId) end
