---@diagnostic disable: duplicate-set-field
if not IsResourceRunning('es_extended') then return end

Framework.Client = {}

local ESX = exports.es_extended:getSharedObject()

function Framework.Client.GetFrameworkName()
    return 'es_extended'
end

-- Player Actions

function Framework.Client.GetIsPlayerLoaded()
    return ESX.IsPlayerLoaded() or false
end

function Framework.Client.GetPlayerData()
    return ESX.GetPlayerData() or nil
end

function Framework.Client.GetPlayerCoords(pedId)
    return vector4(GetEntityCoords(pedId), GetEntityHeading(pedId))
end

function Framework.Client.GetPlayerIdentifier()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData then return nil end
    return PlayerData.identifier or nil
end

function Framework.Client.GetCharacterName()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData then return nil end

    local firstname = PlayerData.firstName
    local lastname  = PlayerData.lastName

    if not firstname or not lastname then return nil end
    return firstname .. ' ' .. lastname
end

function Framework.Client.GetPlayerMetaData(metadata)
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.metadata then return nil end
    return PlayerData.metadata[metadata]
end

function Framework.Client.GetIsPlayerDead()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData then return false end
    return PlayerData.dead or false
end

-- Money Actions

function Framework.Client.GetPlayerMoney(playerId, type)
    type = type or playerId -- playerId is ignored, kept for backwards compatibility
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.accounts then return 0 end

    local formattedType = type == "cash" and "money" or type
    for _, account in pairs(PlayerData.accounts) do
        if account.name == formattedType then
            return account.money or 0
        end
    end

    return 0
end

-- Job Actions

function Framework.Client.GetPlayerJob()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.job then return nil end

    local jobData = PlayerData.job
    if not jobData.grade then return nil end

    return {
        name   = jobData.name,
        label  = jobData.label,
        grade  = {
            name  = jobData.grade_name,
            level = jobData.grade,
        },
        isBoss = jobData.grade_name == "boss",
        onDuty = true,
    }
end

-- Gang Actions

function Framework.Client.GetPlayerGang()
    warn("Gangs are not supported in the ESX Framework")
    return false
end

-- Events

RegisterNetEvent('esx:playerLoaded', function()
    Wait(1500)
    TriggerEvent(RESOURCE_NAME .. ':client:player-loaded')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent(RESOURCE_NAME .. ':client:player-unloaded')
end)

RegisterNetEvent('esx:setJob', function(job)
    TriggerEvent(RESOURCE_NAME .. ':client:player-job-updated', job)
end)

return Framework