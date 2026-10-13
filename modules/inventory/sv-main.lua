local Config = require "config.config"

--- True when `resource` is the inventory this server runs. Config.Inventory pins one,
--- "auto" uses whichever supported inventory is started.
---@param resource string
---@return boolean
local function usesInventory(resource)
    return Config.Inventory == resource
        or (Config.Inventory == "auto" and GetResourceState(resource) == "started")
end

--- Checks whether a player has the specified item(s) in their inventory.
--- Supports: codem-inventory, core_inventory, jpr-inventory, origen_inventory,
--- ox_inventory, ps-inventory, qb-inventory, tgiann-inventory.
---@param playerId number The server-side player source ID.
---@param items string|table A single item name (string) or a key-value table of { [itemName] = requiredCount }.
---@param count number|nil The required quantity when `items` is a string. Ignored when `items` is a table.
---@return boolean True if the player has the required item(s), false otherwise.
function Modules.Server.Inventory.HasItem(playerId, items, count)
    count = count or 1

    if usesInventory('codem-inventory') then
        return exports['codem-inventory']:HasItem(playerId, items, count)
    elseif usesInventory('core_inventory') then
        return exports['core_inventory']:hasItem(playerId, items, count)
    elseif usesInventory('jpr-inventory') then
        return exports['jpr-inventory']:HasItem(playerId, items, count)
    elseif usesInventory('origen_inventory') then
        if type(items) == 'table' then
            for itemName, itemCount in pairs(items) do
                if not exports.origen_inventory:HasItem(playerId, itemName, itemCount) then return false end
            end

            return true
        else
            return exports.origen_inventory:HasItem(playerId, items, count)
        end
    elseif usesInventory('ox_inventory') then
        if type(items) == 'table' then
            for itemName, itemCount in pairs(items) do
                if exports.ox_inventory:GetItemCount(playerId, itemName) < itemCount then return false end
            end

            return true
        else
            return exports.ox_inventory:GetItemCount(playerId, items) >= count
        end
    elseif usesInventory('ps-inventory') then
        return exports['ps-inventory']:HasItem(playerId, items, count)
    elseif usesInventory('qb-inventory') then
        return exports['qb-inventory']:HasItem(playerId, items, count)
    elseif usesInventory('tgiann-inventory') then
        return exports["tgiann-inventory"]:HasItem(playerId, items, count)
    else
        error(("No supported inventory found (Config.Inventory = '%s')."):format(tostring(Config.Inventory)))
    end
end

lib.callback.register('hype-core:server:has-item', function(source, items, count)
    if not source then return false end
    local playerId = source

    return Modules.Server.Inventory.HasItem(playerId, items, count)
end)

--- Checks whether a player has enough inventory capacity to carry additional items.
--- Supports: codem-inventory (always true), core_inventory, jpr-inventory, origen_inventory,
--- ox_inventory, ps-inventory, qb-inventory, tgiann-inventory.
---@param playerId number The server-side player source ID.
---@param itemName string The name of the item to check carry capacity for.
---@param count number The quantity of the item to check.
---@return boolean, string|nil True if the player can carry the item, false otherwise. Some inventories also return a reason string on failure.
function Modules.Server.Inventory.CanCarryItem(playerId, itemName, count)
    if usesInventory('codem-inventory') then
        return true
    elseif usesInventory('core_inventory') then
        return exports['core_inventory']:canCarry(playerId, itemName, count)
    elseif usesInventory('jpr-inventory') then
        return exports["jpr-inventory"]:CanAddItem(playerId, itemName, count)
    elseif usesInventory('origen_inventory') then
        return exports.origen_inventory:canCarryItem(playerId, itemName, count, nil)
    elseif usesInventory('ox_inventory') then
        return exports.ox_inventory:CanCarryItem(playerId, itemName, count, nil)
    elseif usesInventory('ps-inventory') then
        local canAdd, reason = exports['ps-inventory']:CanAddItem(playerId, itemName, count)
        return canAdd, reason
    elseif usesInventory('qb-inventory') then
        local canAdd, reason = exports['qb-inventory']:CanAddItem(playerId, itemName, count)
        return canAdd, reason
    elseif usesInventory('tgiann-inventory') then
        return exports["tgiann-inventory"]:CanCarryItem(playerId, itemName, count)
    else
        error(("No supported inventory found (Config.Inventory = '%s')."):format(tostring(Config.Inventory)))
    end
end

--- Adds an item to a player's inventory.
--- Supports: codem-inventory, core_inventory, jpr-inventory, origen_inventory,
--- ox_inventory, ps-inventory, qb-inventory, tgiann-inventory.
---@param playerId number The server-side player source ID.
---@param itemName string The internal name of the item to add.
---@param count number The quantity of the item to add.
---@param metadata table|nil Optional metadata table to attach to the item (e.g. durability, serial number).
---@return boolean|any, any|nil Returns the success result from the underlying inventory export. Some inventories return a second response value.
function Modules.Server.Inventory.AddItem(playerId, itemName, count, metadata)
    if usesInventory('codem-inventory') then
        return exports['codem-inventory']:AddItem(playerId, itemName, count, nil, metadata)
    elseif usesInventory('core_inventory') then
        return exports['core_inventory']:addItem(playerId, itemName, count, metadata)
    elseif usesInventory('jpr-inventory') then
        return exports['jpr-inventory']:AddItem(playerId, itemName, count, nil, metadata, '')
    elseif usesInventory('origen_inventory') then
        return exports.origen_inventory:addItem(playerId, itemName, count, metadata, nil, true)
    elseif usesInventory('ox_inventory') then
        local success, response = exports.ox_inventory:AddItem(playerId, itemName, count, metadata, nil)

        return success, response
    elseif usesInventory('ps-inventory') then
        return exports['ps-inventory']:AddItem(playerId, itemName, count, false, metadata, '')
    elseif usesInventory('qb-inventory') then
        return exports['qb-inventory']:AddItem(playerId, itemName, count, false, metadata, '')
    elseif usesInventory('tgiann-inventory') then
        return exports["tgiann-inventory"]:AddItem(playerId, itemName, count, nil, metadata, false)
    else
        error(("No supported inventory found (Config.Inventory = '%s')."):format(tostring(Config.Inventory)))
    end
end

--- Removes an item from a player's inventory.
--- Supports: codem-inventory, core_inventory, jpr-inventory, origen_inventory,
--- ox_inventory, ps-inventory, qb-inventory, tgiann-inventory.
---@param playerId number The server-side player source ID.
---@param itemName string The internal name of the item to remove.
---@param count number The quantity of the item to remove.
---@return boolean|any, any|nil Returns the success result from the underlying inventory export. Some inventories return a second response value.
function Modules.Server.Inventory.RemoveItem(playerId, itemName, count)
    if usesInventory('codem-inventory') then
        return exports['codem-inventory']:RemoveItem(playerId, itemName, count)
    elseif usesInventory('core_inventory') then
        return exports['core_inventory']:removeItem(playerId, itemName, count)
    elseif usesInventory('jpr-inventory') then
        return exports['jpr-inventory']:RemoveItem(playerId, itemName, count, nil, '')
    elseif usesInventory('origen_inventory') then
        return exports.origen_inventory:removeItem(playerId, itemName, count, nil, nil, false)
    elseif usesInventory('ox_inventory') then
        local success, response = exports.ox_inventory:RemoveItem(playerId, itemName, count, nil, nil)

        return success, response
    elseif usesInventory('ps-inventory') then
        return exports['ps-inventory']:RemoveItem(playerId, itemName, count, false, '')
    elseif usesInventory('qb-inventory') then
        return exports['qb-inventory']:RemoveItem(playerId, itemName, count, false, '')
    elseif usesInventory('tgiann-inventory') then
        return exports["tgiann-inventory"]:RemoveItem(playerId, itemName, count, false, nil)
    else
        error(("No supported inventory found (Config.Inventory = '%s')."):format(tostring(Config.Inventory)))
    end
end