local Config = require "config.config"

---@diagnostic disable: duplicate-set-field
local resourceName = "ZSX_UIV2"
if (Config.ProgressBarSystem == "auto" and GetResourceState(resourceName) ~= "started") or (Config.ProgressBarSystem ~= "auto" and Config.ProgressBarSystem ~= resourceName) then return end

Modules.Client.Progressbar = {}

--- Converts an Ox-style progress bar options table to a ZSX_UIV2-compatible format.
---@param options table|nil The Ox-style options table. Fields: label, duration, canCancel, disable (mouse, move, car, combat), anim (dict, clip, flag), prop (array of prop tables with model, bone, pos, rot).
---@return table|nil The converted ZSX_UIV2-style options table, or the original value if options is nil.
local function convertFromOx(options)
    if not options then return options end
    local prop1 = options.prop?[1] or options.prop or {}
    local prop2 = options.prop?[2] or {}

    return {
        label = options.label,
        duration = options.duration,
        canCancel = options.canCancel,
        disableControls = {
            disable_mouse = options.disable?.mouse,
            disable_walk = options.disable?.move,
            disable_driving = options.disable?.car,
            disable_combat = options.disable?.combat
        },
        anim = options.anim and {
            dict = options.anim.dict,
            clip = options.anim.clip,
            flag = options.anim.flag or 49
        } or nil,
        prop1 = prop1.model and {
            model = prop1.model,
            bone = prop1.bone,
            pos = prop1.pos,
            rot = prop1.rot
        } or nil,
        prop2 = prop2.model and {
            model = prop2.model,
            bone = prop2.bone,
            pos = prop2.pos,
            rot = prop2.rot
        } or nil
    }
end

--- Converts a QB-style progress bar options table to a ZSX_UIV2-compatible format.
---@param options table|nil The QB-style options table. Fields: label, duration, canCancel, controlDisables (disableMouse, disableMovement, disableCarMovement, disableCombat), animation (animDict, anim, flags), prop (model, bone, coords, rotation), propTwo (model, bone, coords, rotation).
---@return table|nil The converted ZSX_UIV2-style options table, or the original value if options is nil.
local function convertFromQB(options)
    if not options then return options end

    return {
        label = options.label,
        duration = options.duration,
        canCancel = options.canCancel,
        disableControls = {
            disable_mouse = options.controlDisables?.disableMouse,
            disable_walk = options.controlDisables?.disableMovement,
            disable_driving = options.controlDisables?.disableCarMovement,
            disable_combat = options.controlDisables?.disableCombat
        },
        anim = options.animation and {
            dict = options.animation.animDict,
            clip = options.animation.anim,
            flag = options.animation.flags or 49
        } or nil,
        prop1 = options.prop and options.prop.model and {
            model = options.prop.model,
            bone = options.prop.bone,
            pos = options.prop.coords,
            rot = options.prop.rotation
        } or nil,
        prop2 = options.propTwo and options.propTwo.model and {
            model = options.propTwo.model,
            bone = options.propTwo.bone,
            pos = options.propTwo.coords,
            rot = options.propTwo.rotation
        } or nil
    }
end

--- Opens a progress bar using the ZSX_UIV2 resource.
--- Awaits completion synchronously using a promise.
---@param options table The progress bar options table in Ox format (or QB format if isQBInput is true).
---@param cb function|nil Optional callback called with (success: boolean) after the progress bar completes or is cancelled.
---@param isQBInput boolean|nil Pass true if the options table is in QB format. Pass false or nil to use Ox format.
---@return boolean True if the progress bar completed successfully, false if it was cancelled or ZSX_UIV2 export is unavailable.
function Modules.Client.Progressbar.Open(options, cb, isQBInput)
    if not exports['ZSX_UIV2'] then return false end

    if isQBInput then
        options = convertFromQB(options)
    else
        options = convertFromOx(options)
    end
    local prom = promise.new()
    exports['ZSX_UIV2']:ProgressBar(
        'fas fa-circle-notch',
        options.label,
        options.duration or 5000,
        function()
            if cb then cb(true) end
            prom:resolve(true)
        end,
        function()
            if cb then cb(false) end
            prom:resolve(false)
        end,
        options.canCancel,
        options.disableControls,
        options.anim,
        options.prop1,
        options.prop2
    )
    return Citizen.Await(prom)
end