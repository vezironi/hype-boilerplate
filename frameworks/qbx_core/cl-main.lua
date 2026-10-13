---@diagnostic disable: duplicate-set-field
if not IsResourceRunning('qbx_core') then return end

Framework.Client = {}

local QBX = exports.qbx_core

--- Returns the name of the active framework.
---@return string Always returns "qbx_core".
function Framework.Client.GetFrameworkName()
    return 'qbx_core'
end

-- Player Actions

--- Checks whether the local player has fully loaded into the session.
---@return boolean True if the player is logged in, false otherwise.
function Framework.Client.GetIsPlayerLoaded()
    return LocalPlayer.state.isLoggedIn or false
end


--- Returns the full QBX player data object for the local player.
---@return table|nil The QBX PlayerData table containing job, gang, money, charinfo, metadata, etc.
function Framework.Client.GetPlayerData()
    local PlayerData = QBX.GetPlayerData()
    return PlayerData or nil
end

--- Returns the world position and heading of a ped as a vector4.
---@param pedId number The entity handle of the ped to read coordinates from.
---@return vector4 A vector4 containing (x, y, z, heading).
function Framework.Client.GetPlayerCoords(pedId)
    return vector4(GetEntityCoords(pedId), GetEntityHeading(pedId))
end

--- Returns the unique citizenid of the local player.
---@return string|nil The player's citizenid string from QBX PlayerData.
function Framework.Client.GetPlayerIdentifier()
    local PlayerData = Framework.Client.GetPlayerData()
    if PlayerData then return PlayerData.citizenid end
    return nil
end

--- Returns the full display name of the local player's character.
---@return string|nil The character's first and last name concatenated with a space.
function Framework.Client.GetCharacterName()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.charinfo then return nil end
    return PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname
end

--- Returns a specific metadata value from the local player's data.
---@param metadata string The metadata key to retrieve (e.g. "hunger", "thirst", "isdead").
---@return any The value stored under the given metadata key, or nil if not found.
function Framework.Client.GetPlayerMetaData(metadata)
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.metadata then return nil end
    return PlayerData.metadata[metadata]
end

--- Checks whether the local player's character is currently dead or in last stand.
---@return boolean True if the player is dead or in last stand, false otherwise.
function Framework.Client.GetIsPlayerDead()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.metadata then return false end
    return PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or false
end

-- Money Actions

--- Returns the local player's balance for a money type.
--- Maps "money" to "cash" to match QBX money naming.
---@param playerId number|string|nil Ignored, kept for backwards compatibility. May also be the money type.
---@param type string|nil The money type to query (e.g. "cash", "bank").
---@return number The money balance, or 0 if not available.
function Framework.Client.GetPlayerMoney(playerId, type)
    type = type or playerId
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.money then return 0 end

    local formattedType = type == "money" and "cash" or type
    return PlayerData.money[formattedType] or 0
end

-- Job Actions

--- Returns a normalised job data table for the local player.
---@return table|nil A table with fields: name, label, grade.name, grade.level, isBoss, onDuty.
function Framework.Client.GetPlayerJob()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.job or not PlayerData.job.grade then return nil end

    local jobData = PlayerData.job

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

--- Returns a normalised gang data table for the local player.
---@return table|nil A table with fields: name, label, grade.name, grade.level, isBoss.
function Framework.Client.GetPlayerGang()
    local PlayerData = Framework.Client.GetPlayerData()
    if not PlayerData or not PlayerData.gang or not PlayerData.gang.grade then return nil end

    local gangData = PlayerData.gang

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