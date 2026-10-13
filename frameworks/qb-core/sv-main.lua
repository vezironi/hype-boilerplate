---@diagnostic disable: duplicate-set-field
if not IsResourceRunning('qb-core') then return end
if IsResourceRunning('qbx_core') then return end

Framework.Server = {}

local QBCore = exports['qb-core']:GetCoreObject()

function Framework.Server.GetFrameworkName()
    return 'qb-core'
end

-- Player Actions

function Framework.Server.GetPlayers()
    return QBCore.Functions.GetPlayers()
end


function Framework.Server.GetPlayer(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    return Player and Player or nil
end

function Framework.Server.PlayerIsAdmin(playerId)
    return IsPlayerAceAllowed(tostring(playerId), "command") or false
end

function Framework.Server.GetPlayerByIdentifier(citizenid)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    return Player and Player or nil
end

function Framework.Server.GetPlayerSource(citizenid)
    local Player = Framework.Server.GetPlayerByIdentifier(citizenid)
    return Player and Player.PlayerData.source or nil
end

function Framework.Server.GetPlayerIdentifier(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    return Player and Player.PlayerData.citizenid or nil
end

function Framework.Server.GetCharacterName(playerId, split)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then return nil end

    local firstname = Player.PlayerData.charinfo.firstname
    local lastname  = Player.PlayerData.charinfo.lastname

    if split then
        return firstname, lastname
    end

    if not firstname or not lastname then return nil end
    return firstname .. " " .. lastname
end

function Framework.Server.GetPlayerBirthday(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then return nil end
    return Player.PlayerData.charinfo.birthdate or nil
end

function Framework.Server.GetPlayerPhoneNumber(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then return nil end
    return Player.PlayerData.charinfo.phone or nil
end

function Framework.Server.GetPlayerGender(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then return nil end
    return (Player.PlayerData.charinfo.gender == 0 and 'Male' or 'Female') or nil
end

function Framework.Server.GetPlayerLicense(playerId, license)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData then return nil end

    local licenses = Player.Functions.GetMetaData('licenses')
    local isHave = licenses[license]

    return isHave
end

-- Money Actions

function Framework.Server.GetPlayerMoney(playerId, type)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return 0 end
    local formattedType = type == "money" and "cash" or type
    return Player.Functions.GetMoney(formattedType)
end

function Framework.Server.AddPlayerMoney(playerId, type, amount)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return 0 end
    local formattedType = type == "money" and "cash" or type
    return Player.Functions.AddMoney(formattedType, amount)
end

function Framework.Server.RemovePlayerMoney(playerId, type, amount)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return 0 end
    local formattedType = type == "money" and "cash" or type
    local currentMoney = Framework.Server.GetPlayerMoney(playerId, formattedType)
    if amount > currentMoney then return false end
    return Player.Functions.RemoveMoney(formattedType, amount)
end

-- Job Actions

function Framework.Server.GetPlayerJob(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData or not Player.PlayerData.job then return nil end

    local jobData = Player.PlayerData.job
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

function Framework.Server.SetPlayerJob(playerId, job, grade)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return false end
    return Player.Functions.SetJob(job, grade or 0) ~= false
end

-- Gang Actions

function Framework.Server.GetPlayerGang(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData or not Player.PlayerData.gang then return nil end

    local gangData = Player.PlayerData.gang
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

-- Metadata Actions

function Framework.Server.GetPlayerMetaData(playerId, key)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.PlayerData or not Player.PlayerData.metadata then return nil end
    return Player.PlayerData.metadata[key]
end

function Framework.Server.SetPlayerMetaData(playerId, key, value)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return false end
    Player.Functions.SetMetaData(key, value)
    return true
end

-- Usable Item Actions

function Framework.Server.RegisterUsableItem(itemName, cb)
    local func = function(playerId, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(playerId, itemData)
    end
    QBCore.Functions.CreateUseableItem(itemName, func)
end

-- Events

RegisterNetEvent("QBCore:Server:OnPlayerLoaded", function()
    local playerId = source
    Wait(1500)
    TriggerEvent('hype-core:server:player-loaded', playerId)
end)

AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
    local playerId = src or source
    TriggerEvent(RESOURCE_NAME .. ':server:player-unloaded', playerId)
end)

AddEventHandler("QBCore:Server:OnJobUpdate", function(src, job)
    local playerId = src or source
    TriggerEvent(RESOURCE_NAME .. ':server:player-job-updated', playerId, job or nil)
end)

AddEventHandler("playerDropped", function()
    local playerId = source
    if not playerId then return false end
    TriggerEvent(RESOURCE_NAME .. ':server:player-unloaded', playerId)
end)

return Framework