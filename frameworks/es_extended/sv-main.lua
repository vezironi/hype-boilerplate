---@diagnostic disable: duplicate-set-field
if not IsResourceRunning('es_extended') then return end

Framework.Server = {}

local ESX = exports.es_extended:getSharedObject()

function Framework.Server.GetFrameworkName()
    return 'es_extended'
end

-- Player Actions

function Framework.Server.GetPlayers()
    local players = {}
    for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
        players[#players + 1] = xPlayer.source
    end
    return players
end

function Framework.Server.GetPlayer(playerId)
    local Player = ESX.GetPlayerFromId(playerId)
    return Player and Player or nil
end

function Framework.Server.PlayerIsAdmin(playerId)
    return IsPlayerAceAllowed(tostring(playerId), "command") or false
end

function Framework.Server.GetPlayerByIdentifier(citizenid)
    local Player = ESX.GetPlayerFromIdentifier(citizenid)
    return Player or nil
end

function Framework.Server.GetPlayerSource(citizenid)
    local Player = Framework.Server.GetPlayerByIdentifier(citizenid)
    return Player and Player.source or nil
end

function Framework.Server.GetPlayerIdentifier(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return nil end
    return Player.getIdentifier() or nil
end

function Framework.Server.GetCharacterName(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return nil end
    return Player.getName() or nil
end

function Framework.Server.GetPlayerBirthday(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return nil end
    return Player.get('dateofbirth') or nil
end

function Framework.Server.GetPlayerPhoneNumber(playerId)
    warn("Phone numbers are not supported in the ESX Framework")
    return false
end

function Framework.Server.GetPlayerGender(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return nil end
    local sex = Player.get('sex')
    if not sex then return nil end

    return sex == 'm' and 'Male' or 'Female'
end

function Framework.Server.GetPlayerLicense(playerId, license)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return nil end

    if GetResourceState('esx_license') ~= 'started' then return false end

    local p = promise.new()
    TriggerEvent('esx_license:checkLicense', playerId, license, function(hasLicense)
        p:resolve(hasLicense or false)
    end)

    return Citizen.Await(p)
end

-- Money Actions

function Framework.Server.GetPlayerMoney(playerId, type)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return 0 end

    local formattedType = type == "cash" and "money" or type
    local account = Player.getAccount(formattedType)
    if not account then return 0 end

    return account.money or 0
end

function Framework.Server.AddPlayerMoney(playerId, type, amount)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return 0 end

    local formattedType = type == "cash" and "money" or type
    Player.addAccountMoney(formattedType, amount)
    return true
end

function Framework.Server.RemovePlayerMoney(playerId, type, amount)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return 0 end

    local formattedType = type == "cash" and "money" or type
    local currentMoney = Framework.Server.GetPlayerMoney(playerId, formattedType)
    if amount > currentMoney then return false end

    Player.removeAccountMoney(formattedType, amount)
    return true
end

-- Job Actions

function Framework.Server.GetPlayerJob(playerId)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player or not Player.job then return nil end

    local jobData = Player.job
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

function Framework.Server.SetPlayerJob(playerId, job, grade)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return false end
    if not ESX.DoesJobExist(job, grade or 0) then return false end
    Player.setJob(job, grade or 0)
    return true
end

-- Gang Actions

function Framework.Server.GetPlayerGang(playerId)
    warn("Gangs are not supported in the ESX Framework")
    return false
end

-- Metadata Actions

function Framework.Server.GetPlayerMetaData(playerId, key)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return nil end
    return Player.getMeta(key)
end

function Framework.Server.SetPlayerMetaData(playerId, key, value)
    local Player = Framework.Server.GetPlayer(playerId)
    if not Player then return false end
    Player.setMeta(key, value)
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
    ESX.RegisterUsableItem(itemName, func)
end

-- Events

AddEventHandler("esx:playerLoaded", function(src)
    local playerId = src or source
    Wait(1500)
    TriggerEvent(RESOURCE_NAME .. ':server:player-loaded', playerId)
end)

AddEventHandler("esx:playerLogout", function(src)
    local playerId = src or source
    TriggerEvent(RESOURCE_NAME .. ':server:player-unloaded', playerId)
end)

AddEventHandler("esx:setJob", function(src, job)
    local playerId = src or source
    TriggerEvent(RESOURCE_NAME .. ':server:player-job-updated', playerId, job or nil)
end)

AddEventHandler("playerDropped", function()
    local playerId = source
    if not playerId then return false end
    TriggerEvent(RESOURCE_NAME .. ':server:player-unloaded', playerId)
end)

return Framework