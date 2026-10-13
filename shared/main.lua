local Config = require "config.config"

RESOURCE_NAME = GetCurrentResourceName()

lib.locale(Config.Locale)

---@param resource string
---@return boolean
function IsResourceRunning(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end