local Config = require "config.config"

---@diagnostic disable: duplicate-set-field
local resourceName = "qb-target"
if (Config.Target == "auto" and GetResourceState(resourceName) ~= "started") or (Config.Target ~= "auto" and Config.Target ~= resourceName) then return end
if Config.Target == "auto" and GetResourceState("ox_target") == "started" then return end

Modules.Client.Target = {}

local qb_target = exports['qb-target']
local targetZones = {}

--- Normalises a target options array for qb-target compatibility.
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

--- Scans a target options array and returns the largest `distance` value found.
--- Used to set the interaction distance for qb-target zones and entities.
---@param data table Array of target option tables, each optionally containing a `distance` field.
---@return number The largest distance value found, or 2.0 if none are specified.
local function getLargestDistance(data)
    local largestDistance = -1
    for _, v in pairs(data) do
        if v.distance and v.distance > largestDistance then
            largestDistance = v.distance
        end
    end
    return largestDistance ~= -1 and largestDistance or 2.0
end

--- Adds target interaction options to one or more local (non-networked) entities.
---@param entities number|number[] A single entity handle or an array of entity handles.
---@param options table Array of normalised target option tables.
---@return nil
function Modules.Client.Target.AddLocalEntity(entities, options)
    options = fixOptions(options)
    qb_target:AddTargetEntity(entities, {
        options = options,
        distance = getLargestDistance(options)
    })
end

--- Removes target interaction options from a local entity.
---@param entity number The entity handle to remove options from.
---@param labels string|string[]|nil The option label(s) to remove. Pass nil to remove all.
---@return nil
function Modules.Client.Target.RemoveLocalEntity(entity, labels)
    qb_target:RemoveTargetEntity(entity, labels)
end

--- Adds target interaction options to all entities matching one or more model hashes.
---@param models number|number[] A single model hash or an array of model hashes.
---@param options table Array of normalised target option tables.
---@return nil
function Modules.Client.Target.AddModel(models, options)
    options = fixOptions(options)
    qb_target:AddTargetModel(models, {
        options = options,
        distance = getLargestDistance(options),
    })
end

--- Removes all target interaction options from entities matching a model hash.
---@param model number The model hash to remove options from.
---@return nil
function Modules.Client.Target.RemoveModel(model)
    qb_target:RemoveTargetModel(model)
end

--- Creates a box-shaped target zone at the given world coordinates.
---@param name string A unique identifier for this zone used for later removal.
---@param coords vector3 The centre position of the box in world space.
---@param size vector3 The dimensions of the box (x = width, y = depth, z = height).
---@param heading number The rotation of the box in degrees.
---@param options table Array of target option tables to attach to the zone.
---@param debug boolean|nil Unused, kept for API compatibility.
---@return string|nil The zone name, or nil if options is empty.
function Modules.Client.Target.AddBoxZone(name, coords, size, heading, options, debug)
    options = fixOptions(options or {})
    if not next(options) then return end

    qb_target:AddBoxZone(name, coords, size.x, size.y, {
        name = name,
        debugPoly = Config.Debug,
        heading = heading,
        minZ = coords.z - (size.z * 0.5),
        maxZ = coords.z + (size.z * 0.5),
    }, {
        options = options,
        distance = getLargestDistance(options),
    })

    targetZones[#targetZones + 1] = { name = name, creator = GetInvokingResource() }

    return name
end

--- Creates a sphere-shaped target zone at the given world coordinates.
---@param name string A unique identifier for this zone used for later removal.
---@param coords vector3 The centre position of the sphere in world space.
---@param radius number The radius of the sphere zone in metres.
---@param options table Array of target option tables to attach to the zone.
---@param debug boolean|nil Unused, kept for API compatibility.
---@return string The zone name.
function Modules.Client.Target.AddSphereZone(name, coords, radius, options, debug)
    options = fixOptions(options)
    qb_target:AddCircleZone(name, coords, radius, {
        name = name,
        debugPoly = Config.Debug,
    }, {
        options = options,
        distance = getLargestDistance(options),
    })

    targetZones[#targetZones + 1] = { name = name, creator = GetInvokingResource() }

    return name
end

--- Removes a previously created target zone by its name.
---@param name string The unique zone name passed to AddBoxZone or AddSphereZone.
---@return nil
function Modules.Client.Target.RemoveZone(name)
    if not name then return end

    for index, data in ipairs(targetZones) do
        if data.name == name then
            qb_target:RemoveZone(name)
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
            qb_target:RemoveZone(target.name)
            table.remove(targetZones, index)
        end
    end
end)
