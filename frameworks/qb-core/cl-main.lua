---@diagnostic disable: duplicate-set-field
if not IsResourceRunning('qb-core') then return end
if IsResourceRunning('qbx_core') then return end

Framework.Client = {}

local QBCore = exports['qb-core']:GetCoreObject()

function Framework.Client.GetFrameworkName()
    return 'qb-core'
end

-- Player Actions

function Framework.Client.GetIsPlayerLoaded()
    return LocalPlayer.state.isLoggedIn or false
end


function Framework.Client.GetPlayerData()
    return QBCore.Functions.GetPlayerData() or nil
end

function Framework.Client.GetPlayerCoords(pedId)
    return vector4(GetEntityCoords(pedId), GetEntityHeading(pedId))
end

function Framework.Client.GetPlayerIdentifier()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData then return nil end
    return PlayerData.citizenid or nil
end

function Framework.Client.GetCharacterName()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.charinfo then return nil end

    local firstname = PlayerData.charinfo.firstname
    local lastname  = PlayerData.charinfo.lastname

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
    if not PlayerData or not PlayerData.metadata then return false end
    return PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or false
end

-- Money Actions

function Framework.Client.GetPlayerMoney(playerId, type)
    type = type or playerId -- playerId is ignored, kept for backwards compatibility
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.money then return 0 end

    local formattedType = type == "money" and "cash" or type
    return PlayerData.money[formattedType] or 0
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
            name  = jobData.grade.name,
            level = jobData.grade.level,
        },
        isBoss = jobData.isboss,
        onDuty = jobData.onduty,
    }
end

-- Gang Actions

function Framework.Client.GetPlayerGang()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.gang then return nil end

    local gangData = PlayerData.gang
    if not gangData.grade then return nil end

    return {
        name   = gangData.name,
        label  = gangData.label,
        grade  = {
            name  = gangData.grade.name,
            level = gangData.grade.level,
        },
        isBoss = gangData.isboss,
    }
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    TriggerEvent(RESOURCE_NAME .. ':client:player-loaded')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent(RESOURCE_NAME .. ':client:player-unloaded')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
    TriggerEvent(RESOURCE_NAME .. ':client:player-job-updated', data)
end)

return Framework