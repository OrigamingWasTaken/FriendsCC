---@meta

---@class fsAPI
fs = {}

---@param path string
---@return string[] files
---@nodiscard
function fs.list(path) end

---@param pattern string
---@return string[] files
---@nodiscard
function fs.find(pattern) end

---@param path string
---@return boolean
---@nodiscard
function fs.exists(path) end

---@param path string
---@return boolean
---@nodiscard
function fs.isDir(path) end

---@param path string
---@return boolean
---@nodiscard
function fs.isReadOnly(path) end

---@param path string
---@return string name
---@nodiscard
function fs.getName(path) end

---@param path string
---@return string dir
---@nodiscard
function fs.getDir(path) end

---@param path string
---@return number size
---@nodiscard
function fs.getSize(path) end

---@param path string
---@return number|"unlimited" freeSpace
---@nodiscard
function fs.getFreeSpace(path) end

---@param path string
---@return string|nil drive
---@nodiscard
function fs.getDrive(path) end

---@param path string
---@return number|nil capacity
---@nodiscard
function fs.getCapacity(path) end

---@param path string
function fs.makeDir(path) end

---@param from string
---@param to string
function fs.move(from, to) end

---@param from string
---@param to string
function fs.copy(from, to) end

---@param path string
function fs.delete(path) end

---@param base string
---@param ... string
---@return string combined
---@nodiscard
function fs.combine(base, ...) end

---@class ReadHandle
---@field readLine fun(self: ReadHandle, withTrailing?: boolean): string|nil
---@field readAll fun(self: ReadHandle): string|nil
---@field read fun(self: ReadHandle, count?: number): string|nil
---@field close fun(self: ReadHandle)

---@class WriteHandle
---@field write fun(self: WriteHandle, text: string)
---@field writeLine fun(self: WriteHandle, text: string)
---@field flush fun(self: WriteHandle)
---@field close fun(self: WriteHandle)

---@class BinaryReadHandle
---@field read fun(self: BinaryReadHandle, count?: number): number|string|nil
---@field readAll fun(self: BinaryReadHandle): string|nil
---@field readLine fun(self: BinaryReadHandle, withTrailing?: boolean): string|nil
---@field close fun(self: BinaryReadHandle)
---@field seek fun(self: BinaryReadHandle, whence?: string, offset?: number): number

---@class BinaryWriteHandle
---@field write fun(self: BinaryWriteHandle, value: number|string)
---@field flush fun(self: BinaryWriteHandle)
---@field close fun(self: BinaryWriteHandle)
---@field seek fun(self: BinaryWriteHandle, whence?: string, offset?: number): number

---@param path string
---@param mode string "r"|"w"|"a"|"rb"|"wb"|"ab"
---@return ReadHandle|WriteHandle|BinaryReadHandle|BinaryWriteHandle|nil handle
---@return string|nil error
function fs.open(path, mode) end

---@param partial string
---@param path string
---@param includeFiles? boolean
---@param includeDirs? boolean
---@return string[] completions
---@nodiscard
function fs.complete(partial, path, includeFiles, includeDirs) end

---@param path string
---@return {size: number, isDir: boolean, isReadOnly: boolean, created: number, modified: number}
---@nodiscard
function fs.attributes(path) end

---@param path string
---@return boolean
---@nodiscard
function fs.isDriveRoot(path) end
