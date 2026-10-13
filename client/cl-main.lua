local Config <const> = require "config.config"

local isOpen = false

local function openUI()
    if isOpen then return end

    isOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'nui/open',
        payload = {
            locales = lib.getLocales(),
        },
    })
end

RegisterNUICallback('nui/close', function(_, cb)
    isOpen = false

    SetNuiFocus(false, false)
    cb({ success = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE_NAME then return end

    SetNuiFocus(false, false)
end)

if Config.Command.enable then
    RegisterCommand(Config.Command.name, openUI, false)

    if Config.Command.key then
        RegisterKeyMapping(Config.Command.name, Config.Command.help, 'keyboard', Config.Command.key)
    end
end
