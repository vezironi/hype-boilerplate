local Config = require "config.config"

--- Sends a UI notification to the local player using the configured notification resource.
--- Supports: okokNotify, ps-ui, ox_lib. Falls back silently if none are available.
--- The active system is determined by `Config.Notifications` ("auto" auto-detects).
---@param title string The notification title displayed in the header.
---@param message string The notification body text.
---@param time number|nil Duration in milliseconds the notification stays visible. Defaults to 5000.
---@param type string|nil The notification style/type (e.g. "success", "error", "info", "warning"). Defaults to "success".
---@return nil
function Modules.Client.Notify.SendNotify(title, message, time, type)
    type = type or "success"
    time = time or 5000

    if (Config.Notifications == "auto" and GetResourceState("okokNotify") == "started") or Config.Notifications == "okokNotify" then
        exports["okokNotify"]:Alert(title, message, time, type)
    elseif (Config.Notifications == "auto" and GetResourceState("ps-ui") == "started") or Config.Notifications == "ps-ui" then
        exports["ps-ui"]:Notify(message, type, time)
    elseif (Config.Notifications == "auto" and GetResourceState("ox_lib") == "started") or Config.Notifications == "ox_lib" then
        exports["ox_lib"]:notify({
            title = title,
            description = message,
            type = type
        })
    else
        error("No supported notification system found")
    end
end

RegisterNetEvent("hype-core:client:send-notify", function(...)
    Modules.Client.Notify.SendNotify(...)
end)