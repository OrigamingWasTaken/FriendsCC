---@meta

---@class ioAPI
io = {}

---@param path string
---@param mode? string
---@return file*|nil handle
---@return string|nil error
function io.open(path, mode) end

---@param file? file*
function io.close(file) end

---@param ... string|number
---@return string|number|nil ...
function io.read(...) end

---@param ... string|number
function io.write(...) end

---@param path? string
---@param ... string|number
---@return fun(): string|nil
function io.lines(path, ...) end

---@param file? string|file*
---@return file*
function io.input(file) end

---@param file? string|file*
---@return file*
function io.output(file) end
