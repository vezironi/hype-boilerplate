local Config = require "config.config"

---@diagnostic disable: duplicate-set-field
local resourceName = "progressbar"
if (Config.ProgressBarSystem == "auto" and GetResourceState(resourceName) ~= "started") or (Config.ProgressBarSystem ~= "auto" and Config.ProgressBarSystem ~= resourceName) then return end

Modules.Client.Progressbar = {}

--- Converts an Ox-style progress bar options table to a qb-progressbar-compatible format.
---@param options table|nil The Ox-style options table. Fields: duration, label, useWhileDead, canCancel, disable (move, car, mouse, combat), anim (dict, clip, flag), prop (array of prop tables with model, bone, pos, rot).
---@return table|nil The converted QB-style options table, or the original value if options is nil.
local function convertFromOx(options)
    if not options then return options end
    local prop1 = options.prop?[1] or options.prop or {}
    local prop2 = options.prop?[2] or {}
    return {
        name = options.label,
        duration = options.duration,
        label = options.label,
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        controlDisables = {
            disableMovement = options.disable?.move,
            disableCarMovement = options.disable?.car,
            disableMouse = options.disable?.mouse,
            disableCombat = options.disable?.combat
        },
        animation = {
            animDict = options.anim?.dict,
            anim = options.anim?.clip,
            flags = options.anim?.flag or 49
        },
        prop = {
            model = prop1.model,
            bone = prop1.bone,
            coords = prop1.pos,
            rotation = prop1.rot
        },
        propTwo = {
            model = prop2.model,
            bone = prop2.bone,
            coords = prop2.pos,
            rotation = prop2.rot
        }
    }
end

--- Opens a progress bar using the qb-progressbar resource.
--- Awaits completion synchronously using a promise.
---@param options table The progress bar options table in QB format (or Ox format if isQBInput is false/nil).
---@param cb function|nil Optional callback called with (success: boolean) after the progress bar completes or is cancelled.
---@param isQBInput boolean|nil Pass true if the options table is already in QB format. Pass false or nil to convert from Ox format.
---@return boolean True if the progress bar completed successfully (not cancelled), false if it was cancelled.
function Modules.Client.Progressbar.Open(options, cb, isQBInput)
    if not exports['progressbar'] then return false end

    if not isQBInput then
        options = convertFromOx(options)
    end

    local prom = promise.new()
    exports['progressbar']:Progress(options, function(cancelled)
        if cb then cb( not cancelled) end
        prom:resolve(not cancelled)
    end)
    return Citizen.Await(prom)
end