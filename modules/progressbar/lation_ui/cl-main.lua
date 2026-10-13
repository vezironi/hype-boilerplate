local Config = require "config.config"

---@diagnostic disable: duplicate-set-field
local resourceName = "lation_ui"
if (Config.ProgressBarSystem == "auto" and GetResourceState(resourceName) ~= "started") or (Config.ProgressBarSystem ~= "auto" and Config.ProgressBarSystem ~= resourceName) then return end

Modules.Client.Progressbar = {}

--- Converts a QB-style progress bar options table to a lation_ui-compatible format.
---@param options table|nil The QB-style options table. Fields: duration, label, description, icon, iconColor, iconAnimation, useWhileDead, canCancel, controlDisables, animation, prop, propTwo.
---@return table|nil The converted lation_ui-style options table, or the original value if options is nil.
local function convertFromQB(options)
    if not options then return options end
    local prop1 = options.prop or {}
    local prop2 = options.propTwo or {}
    local props = {
        {
            model = prop1?.model,
            bone = prop1?.bone,
            pos = prop1?.coords,
            rot = prop1?.rotation,
        },
        {
            model = prop2?.model,
            bone = prop2?.bone,
            pos = prop2?.coords,
            rot = prop2?.rotation,
        }
    }
    return {
        duration = options.duration,
        label = options.label,
        description = options?.description,
        icon = options?.icon,
        iconColor = options?.iconColor,
        iconAnimation = options?.iconAnimation,
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        disable = {
            move = options.controlDisables?.disableMovement,
            car = options.controlDisables?.disableCarMovement,
            combat = options.controlDisables?.disableCombat,
            mouse = options.controlDisables?.disableMouse
        },
        anim = {
            dict = options.animation?.animDict,
            clip = options.animation?.anim,
            flag = options.animation?.flags or 49,
        },
        prop = props,
    }
end

--- Converts an Ox-style progress bar options table to a lation_ui-compatible format.
---@param options table|nil The Ox-style options table. Fields: duration, label, description, icon, iconColor, iconAnimation, useWhileDead, canCancel, disable, anim, prop (array of prop tables).
---@return table|nil The converted lation_ui-style options table, or the original value if options is nil.
local function convertFromOx(options)
    if not options then return options end
    local prop1 = options.prop or {}
    local prop2 = options.propTwo or {}
    return {
        duration = options.duration,
        label = options.label,
        description = options?.description,
        icon = options?.icon,
        iconColor = options?.iconColor,
        iconAnimation = options?.iconAnimation,
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        disable = options.disable,
        anim = options.anim,
        prop = {
            {
                model = prop1?.model,
                bone = prop1?.bone,
                pos = prop1?.coords,
                rot = prop1?.rotation,
            },
            {
                model = prop2?.model,
                bone = prop2?.bone,
                pos = prop2?.coords,
                rot = prop2?.rotation,
            }
        },
    }
end

--- Opens a progress bar using the lation_ui resource.
---@param options table The progress bar options table in Ox format (or QB format if isQBInput is true).
---@param cb function|nil Optional callback called with (success: boolean) after the progress bar completes or is cancelled.
---@param isQBInput boolean|nil Pass true if the options table is in QB format so it gets converted automatically. Pass false or nil to use Ox format.
---@return boolean True if the progress bar completed successfully, false if it was cancelled.
function Modules.Client.Progressbar.Open(options, cb, isQBInput)
    if isQBInput then
        options = convertFromQB(options)
    else
        options = convertFromOx(options)
    end

    local success = exports.lation_ui:progressBar(options)

    if cb then cb(success) end
    return success
end