local Config = require "config.config"

Modules.Client.Fuel = {}

--- Returns the current fuel level of a vehicle using the configured fuel resource.
--- Supports: LegacyFuel, ps-fuel, lj-fuel, cdn-fuel, hyon_gas_station, okokGasStation,
--- nd_fuel, myFuel, fast-fuel, ti_fuel, ox_fuel, Renewed-Fuel, rcore_fuel.
---@param vehicle number The entity handle of the vehicle to read fuel from.
---@return number The current fuel level (0–100), or 0 if the entity does not exist or no supported system is configured.
function Modules.Client.Fuel.GetFuel(vehicle)
    if not DoesEntityExist(vehicle) then return 0 end

    if (Config.Fuel == "LegacyFuel" or Config.Fuel == "ps-fuel" or Config.Fuel == "lj-fuel" or Config.Fuel == "cdn-fuel" or Config.Fuel == "hyon_gas_station" or Config.Fuel == "okokGasStation" or Config.Fuel == "nd_fuel" or Config.Fuel == "myFuel" or Config.Fuel == "fast-fuel")  then
        return exports[Config.Fuel]:GetFuel(vehicle)
    elseif Config.Fuel == "ti_fuel" then
        local level = exports["ti_fuel"]:getFuel(vehicle)
        return level
    elseif Config.Fuel == "ox_fuel" or Config.Fuel == "Renewed-Fuel" then
        return GetVehicleFuelLevel(vehicle)
    elseif Config.Fuel == "rcore_fuel" then
        return exports.rcore_fuel:GetVehicleFuelPercentage(vehicle)
    else
        return 0
    end
end


--- Sets the fuel level of a vehicle using the configured fuel resource.
--- Supports: LegacyFuel, ps-fuel, lj-fuel, cdn-fuel, hyon_gas_station, okokGasStation,
--- nd_fuel, myFuel, Renewed-Fuel, fast-fuel, ti_fuel, ox_fuel, rcore_fuel.
--- Throws an error if no valid fuel system is configured.
---@param vehicle number The entity handle of the vehicle to update.
---@param fuel number The desired fuel level to set (typically 0–100).
---@return false|nil Returns false if the entity does not exist, otherwise returns nil after setting fuel.
function Modules.Client.Fuel.SetFuel(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return false end

    if (Config.Fuel == "LegacyFuel" or Config.Fuel == "ps-fuel" or Config.Fuel == "lj-fuel" or Config.Fuel == "cdn-fuel" or Config.Fuel == "hyon_gas_station" or Config.Fuel == "okokGasStation" or Config.Fuel == "nd_fuel" or Config.Fuel == "myFuel" or Config.Fuel == "Renewed-Fuel" or Config.Fuel == "fast-fuel") then
        exports[Config.Fuel]:SetFuel(vehicle, fuel)
    elseif Config.Fuel == "ti_fuel" then
        local level, fuelType = exports["ti_fuel"]:getFuel(vehicle)
        exports["ti_fuel"]:setFuel(vehicle, fuel, fuelType or nil)
    elseif Config.Fuel == "ox_fuel" then
        Entity(vehicle).state.fuel = fuel
    elseif Config.Fuel == "rcore_fuel" then
        exports.rcore_fuel:SetVehicleFuel(vehicle, fuel)
    else
        -- Setup custom fuel system here...
        error("No valid fuel system configured, please set Config.Fuel to your fuel system or setup your own in the else statement.")
    end
end