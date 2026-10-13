local Config <const> = require "config.config"

local debugStatus <const> = {
    ["success"] = "^2[SUCCESS]^0",
    ["error"] = "^1[ERROR]^0",
    ["warning"] = "^3[WARNING]^0",
    ["info"] = "^4[INFO]^0",
}

local context <const> = IsDuplicityVersion() and "SERVER" or "CLIENT"

---@param status "success"|"error"|"warning"|"info"
---@param message string
---@param ... any
function Debug(status, message, ...)
    if not Config.Debug then return end

    local prefix = debugStatus[status] or ("^7[" .. tostring(status) .. "]^0")
    local body = tostring(message or "")

    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, body, ...)
        body = ok and formatted or body
    end

    print("[DEBUG:" .. context .. "] " .. prefix .. " " .. body)
end

---@param inputString string
---@param delimiter string A single character, or a set of characters.
---@return string[]
function SplitString(inputString, delimiter)
    local result = {}

    local pattern = "([^" .. delimiter .. "]+)"

    for match in string.gmatch(inputString, pattern) do
        local trimmedMatch = string.gsub(match, "^%s*(.-)%s*$", "%1")
        table.insert(result, trimmedMatch)
    end

    return result
end

---@param value string
---@return string
function TrimString(value)
    return (string.gsub(value or "", "^%s*(.-)%s*$", "%1"))
end

---@param value number
---@param decimals? integer Defaults to 0.
---@return number
function Round(value, decimals)
    local multiplier = 10 ^ (decimals or 0)
    return math.floor(value * multiplier + 0.5) / multiplier
end

---@param value number
---@param min number
---@param max number
---@return number
function Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

---@param tbl table
---@param value any
---@return boolean
function TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end

    return false
end

---@param tbl table
---@return integer
function TableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

---@generic T : table
---@param tbl T
---@return T
function DeepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end

    local copy = {}
    for key, value in pairs(tbl) do
        copy[key] = type(value) == "table" and DeepCopy(value) or value
    end

    return copy
end

--- Shallow-merges `source` into a copy of `target`. Useful for config overrides.
---@param target table
---@param source table
---@return table
function MergeTable(target, source)
    local result = DeepCopy(target)

    for key, value in pairs(source or {}) do
        result[key] = value
    end

    return result
end

---@param amount number
---@param currency? string Defaults to '$'.
---@return string
function FormatMoney(amount, currency)
    local formatted = tostring(math.floor(math.abs(amount or 0)))

    while true do
        local replacements
        formatted, replacements = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if replacements == 0 then break end
    end

    return ("%s%s%s"):format((amount or 0) < 0 and "-" or "", currency or "$", formatted)
end
