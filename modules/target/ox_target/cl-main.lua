local Config = require "config.config"

---@diagnostic disable: duplicate-set-field
local resourceName = "ox_target"
if (Config.Target == "auto" and GetResourceState(resourceName) ~= "started") or (Config.Target ~= "auto" and Config.Target ~= resourceName) then return end
Modules.Client.Target = {}

local ox_target = exports.ox_target
local targetZones = {}

--- Normalises a target options array for ox_target compatibility.
--- Remaps `onSelect`/`action` to a unified handler, converts server events,
--- and syncs `job`/`groups` fields.
---@param options table Array of target option tables to normalise.
---@return table The same options array with normalised fields.
local function fixOptions(options)
    for index, option in pairs(options) do
        local action = option.onSelect or option.action

        if action then
            local select = function(entityOrData)
                if type(entityOrData) == "table" then
                    return action(entityOrData.entity)
                end

                return action(entityOrData)
            end
            options[index].action = select

            options[index].onSelect = select
        else
            if option.type == "server" and option.event then
                options[index].serverEvent = option.event
                options[index].event = nil
            end
        end

        options[index].job = option.job or option.groups
        options[index].groups = option.groups or option.job

        options[index].jobType = option.jobType

        if option.canInteract then
            options[index].canInteract = option.canInteract
        end
    end

    return options
end

--- Adds target interaction options to one or more local (non-networked) entities.
---@param entities number|number[] A single entity handle or an array of entity handles.
---@param options table Array of normalised target option tables.
---@return nil
function Modules.Client.Target.AddLocalEntity(entities, options)
    options = fixOptions(options)
    ox_target:addLocalEntity(entities, options)
end

--- Removes target interaction options from one or more local entities.
---@param entities number|number[] A single entity handle or an array of entity handles.
---@param optionNames string|string[]|nil The option label(s) to remove. Pass nil to remove all.
---@return nil
function Modules.Client.Target.RemoveLocalEntity(entities, optionNames)
    ox_target:removeLocalEntity(entities, optionNames)
end

--- Adds target interaction options to all entities matching one or more model hashes.
---@param models number|number[] A single model hash or an array of model hashes.
---@param options table Array of normalised target option tables.
---@return nil
function Modules.Client.Target.AddModel(models, options)
    options = fixOptions(options)
    ox_target:addModel(models, options)
end

--- Removes all target interaction options from entities matching a model hash.
---@param model number The model hash to remove options from.
---@return nil
function Modules.Client.Target.RemoveModel(model)
    ox_target:removeModel(model)
end

--- Creates a box-shaped target zone at the given world coordinates.
---@param name string A unique identifier for this zone used for later removal.
---@param coords vector3 The centre position of the box in world space.
---@param size vector3 The dimensions of the box (x = width, y = depth, z = height).
---@param heading number The rotation of the box in degrees.
---@param options table Array of target option tables to attach to the zone.
---@param debug boolean|nil Unused, kept for API compatibility.
---@return number|nil The ox_target zone ID, or nil if options is empty.
function Modules.Client.Target.AddBoxZone(name, coords, size, heading, options, debug)
    options = fixOptions(options or {})
    if not next(options) then return end

    local target = ox_target:addBoxZone({
        coords = coords,
        size = size,
        rotation = heading,
        debug = Config.Debug,
        options = options,
    })

    targetZones[#targetZones + 1] = { name = name, id = target, creator = GetInvokingResource() }

    return target
end

--- Creates a sphere-shaped target zone at the given world coordinates.
---@param name string A unique identifier for this zone used for later removal.
---@param coords vector3 The centre position of the sphere in world space.
---@param radius number The radius of the sphere zone in metres.
---@param options table Array of target option tables to attach to the zone.
---@param debug boolean|nil Unused, kept for API compatibility.
---@return number The ox_target zone ID.
function Modules.Client.Target.AddSphereZone(name, coords, radius, options, debug)
    options = fixOptions(options)
    local target = ox_target:addSphereZone({
        coords = coords,
        radius = radius,
        name = name,
        debug = Config.Debug,
        options = options
    })

    targetZones[#targetZones + 1] = { name = name, id = target, creator = GetInvokingResource() }

    return target
end

--- Removes a previously created target zone by its name.
---@param name string The unique zone name passed to AddBoxZone or AddSphereZone.
---@return nil
function Modules.Client.Target.RemoveZone(name)
    if not name then return end

    for index, data in ipairs(targetZones) do
        if data.name == name then
            ox_target:removeZone(data.id)
            table.remove(targetZones, index)
            break
        end
    end
end

-- Zones are registered under hype-core, so clean up a consumer resource's zones when it stops.
AddEventHandler('onResourceStop', function(resource)
    local isSelf = resource == GetCurrentResourceName()

    for index = #targetZones, 1, -1 do
        local target = targetZones[index]
        if isSelf or target.creator == resource then
            ox_target:removeZone(target.id)
            table.remove(targetZones, index)
        end
    end
end)
