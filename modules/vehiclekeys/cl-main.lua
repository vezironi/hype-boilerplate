local Config = require "config.config"

Modules.Client.Vehiclekeys = {}

--- Grants vehicle keys to the local player using the configured vehicle keys resource.
--- Supports: qb-vehiclekeys, fast-vehiclekeys, 0r-vehiclekeys, qbx_vehiclekeys,
--- jaksam-vehicles-keys, mk_vehiclekeys, qs-vehiclekeys, wasabi_carlock,
--- cd_garage, okokGarage, t1ger_keys, MrNewbVehicleKeys, Renewed, tgiann-hotwire.
--- Throws an error if no valid vehicle keys system is configured.
---@param plate string The vehicle license plate string. Will be uppercased automatically.
---@param vehicleEntity number The entity handle of the vehicle to assign keys for.
---@param origin string|nil Optional origin context. Pass "job" for t1ger_keys job-vehicle key logic.
---@return false|string|nil, string|nil Returns false with "invalid_plate" if the plate is empty, false if the entity does not exist, otherwise nil after granting keys.
function Modules.Client.Vehiclekeys.GiveKeys(plate, vehicleEntity, origin)
    if not DoesEntityExist(vehicleEntity) then return false end
    if not plate or plate == "" then
        return false, "invalid_plate"
    end

    plate = plate:upper()

    if Config.VehicleKeys == "qb-vehiclekeys" then
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    elseif Config.VehicleKeys == "fast-vehiclekeys" then
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    elseif Config.VehicleKeys == "0r-vehiclekeys" then
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    elseif Config.VehicleKeys == "qbx_vehiclekeys" then
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    elseif Config.VehicleKeys == "jaksam-vehicles-keys" then
        TriggerServerEvent("vehicles_keys:selfGiveVehicleKeys", plate)
    elseif Config.VehicleKeys == "mk_vehiclekeys" then
        exports["mk_vehiclekeys"]:AddKey(vehicleEntity)
    elseif Config.VehicleKeys == "qs-vehiclekeys" then
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity))
        exports["qs-vehiclekeys"]:GiveKeys(plate, model)
    elseif Config.VehicleKeys == "wasabi_carlock" then
        exports.wasabi_carlock:GiveKey(plate)
    elseif Config.VehicleKeys == "cd_garage" then
        TriggerEvent("cd_garage:AddKeys", plate)
    elseif Config.VehicleKeys == "okokGarage" then
        TriggerServerEvent("okokGarage:GiveKeys", plate)
    elseif Config.VehicleKeys == "t1ger_keys" then
        if origin == "job" then
            local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity))
            exports['t1ger_keys']:GiveJobKeys(plate, vehicleName, true)
        else
            TriggerServerEvent("t1ger_keys:updateOwnedKeys", plate, true)
        end
    elseif Config.VehicleKeys == "MrNewbVehicleKeys" then
        exports.MrNewbVehicleKeys:GiveKeys(vehicleEntity)
    elseif Config.VehicleKeys == "Renewed" then
        exports["Renewed-Vehiclekeys"]:addKey(plate)
    elseif Config.VehicleKeys == "tgiann-hotwire" then
        exports["tgiann-hotwire"]:CheckKeyInIgnitionWhenSpawn(vehicleEntity, plate)
    else
        error("No valid vehicle keys system configured, please set Config.VehicleKeys to your vehicle keys system or setup your own in the else statement.")
    end
end

--- Removes vehicle keys from the local player using the configured vehicle keys resource.
--- Supports: qs-vehiclekeys, 0r-vehiclekeys, wasabi_carlock, t1ger_keys,
--- MrNewbVehicleKeys, Renewed.
--- Throws an error if no valid vehicle keys system is configured.
---@param plate string The vehicle license plate string. Will be uppercased automatically.
---@param vehicleEntity number The entity handle of the vehicle to remove keys from.
---@return false|string|nil, string|nil Returns false with "invalid_plate" if the plate is empty, false if the entity does not exist, otherwise nil after removing keys.
function Modules.Client.Vehiclekeys.RemoveKeys(plate, vehicleEntity)
    if not DoesEntityExist(vehicleEntity) then return false end
    if not plate or plate == "" then
        return false, "invalid_plate"
    end

    plate = plate:upper()

    if Config.VehicleKeys == "qs-vehiclekeys" then
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity))
        exports["qs-vehiclekeys"]:RemoveKeys(plate, model)
    elseif Config.VehicleKeys == "qbx_vehiclekeys" then
        TriggerEvent("qb-vehiclekeys:client:RemoveKeys", plate)
    elseif Config.VehicleKeys == "0r-vehiclekeys" then
        exports['0r-vehiclekeys']:RemoveKeys(plate)
    elseif Config.VehicleKeys == "wasabi_carlock" then
        exports.wasabi_carlock:RemoveKey(plate)
    elseif Config.VehicleKeys == "t1ger_keys" then
        TriggerServerEvent("t1ger_keys:updateOwnedKeys", plate, false)
    elseif Config.VehicleKeys == "MrNewbVehicleKeys" then
        exports.MrNewbVehicleKeys:RemoveKeys(vehicleEntity)
    elseif Config.VehicleKeys == "Renewed" then
        exports["Renewed-Vehiclekeys"]:removeKey(plate)
    else
        error("No valid vehicle keys system configured, please set Config.VehicleKeys to your vehicle keys system or setup your own in the else statement.")
    end
end