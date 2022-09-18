---@meta
---@param key string
function ClearKey(key) end

---@meta
---@param key string
---@return boolean
function HasKey(key) end


---@meta
---@param key string
---@param value integer
function SetInt(key, value) end

---@meta
---@param key string
---@return integer
function GetInt(key) end


---@meta
---@param key string
---@param value number
function SetFloat(key, value) end

---@meta
---@param key string
---@return number
function GetFloat(key) end


---@meta
---@param key string
---@param value boolean
function SetBool(key, value) end

---@meta
---@param key string
---@return boolean
function GetBool(key) end

---@meta
---@param key string
---@param value string
function SetString(key, value) end

---@meta
---@param key string
---@return string
function GetString(key) end