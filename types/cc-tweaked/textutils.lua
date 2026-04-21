---@meta

---@class textutilsAPI
textutils = {}

---Yields.
---@param text string
---@param rate? number
function textutils.slowWrite(text, rate) end

---Yields.
---@param text string
---@param rate? number
function textutils.slowPrint(text, rate) end

---@param time number
---@param twentyFour? boolean
---@return string
---@nodiscard
function textutils.formatTime(time, twentyFour) end

---Yields.
---@param text string
---@param freeLines? number
---@return number linesWritten
function textutils.pagedPrint(text, freeLines) end

---@param ... string[]|number
function textutils.tabulate(...) end

---Yields.
---@param ... string[]|number
function textutils.pagedTabulate(...) end

---@param value any
---@param options? {compact?: boolean, allow_repetitions?: boolean}
---@return string
---@nodiscard
function textutils.serialize(value, options) end

---@param value any
---@param options? {compact?: boolean, allow_repetitions?: boolean}
---@return string
---@nodiscard
function textutils.serialise(value, options) end

---@param str string
---@return any|nil
function textutils.unserialize(str) end

---@param str string
---@return any|nil
function textutils.unserialise(str) end

---@param value any
---@param unquoteKeys? boolean
---@return string
---@nodiscard
function textutils.serializeJSON(value, unquoteKeys) end

---@param value any
---@param unquoteKeys? boolean
---@return string
---@nodiscard
function textutils.serialiseJSON(value, unquoteKeys) end

---@param str string
---@param options? {parse_null?: boolean, parse_empty_array?: boolean, nbt_style?: boolean}
---@return any|nil
---@return string|nil error
function textutils.unserializeJSON(str, options) end

---@param str string
---@param options? {parse_null?: boolean, parse_empty_array?: boolean, nbt_style?: boolean}
---@return any|nil
---@return string|nil error
function textutils.unserialiseJSON(str, options) end

---@param str string
---@return string
---@nodiscard
function textutils.urlEncode(str) end

---@param searchText string
---@param searchTable? table
---@return string[]
---@nodiscard
function textutils.complete(searchText, searchTable) end

---@type table
textutils.empty_json_array = {}
