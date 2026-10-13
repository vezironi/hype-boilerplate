local Config = require "config.config"

---@diagnostic disable: duplicate-set-field
local resourceName = "ox_lib"
if (Config.ProgressBarSystem == "auto" and GetResourceState(resourceName) ~= "started") or (Config.ProgressBarSystem ~= "auto" and Config.ProgressBarSystem ~= resourceName) then return end

Modules.Client.Progressbar = {}

--- Converts a QB-style progress bar options table to an ox_lib-compatible format.
---@param options table|nil The QB-style options table. Fields: duration, label, useWhileDead, canCancel, controlDisables (disableMovement, disableCarMovement, disableCombat, disableMouse), animation (animDict, anim, flags), prop, propTwo.
---@return table|nil The converted ox_lib-style options table, or the original value if options is nil.
local function convertFromQB(options)
    if not options then return options end
    local prop1 = options.prop or {}
    local prop2 = options.propTwo or {}
    local props = {
        {
            model = prop1.model,
            bone = prop1.bone,
            pos = prop1.coords,
            rot = prop1.rotation,
        },
        {
            model = prop2.model,
            bone = prop2.bone,
            pos = prop2.coords,
            rot = prop2.rotation,
        }
    }
    return {
        duration = options.duration,
        label = options.label,
        position = 'bottom',
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

--- Opens a progress bar or circle using the ox_lib resource.
--- Automatically selects `progressCircle` or `progressBar` based on `options.style`.
---@param options table The progress bar options table in Ox format (or QB format if isQBInput is true). Include `style = "circle"` to show a circle instead of a bar.
---@param cb function|nil Optional callback called with (success: boolean) after the progress bar completes or is cancelled.
---@param isQBInput boolean|nil Pass true if the options table is in QB format so it gets converted automatically.
---@return boolean True if the progress bar completed successfully, false if it was cancelled.
function Modules.Client.Progressbar.Open(options, cb, isQBInput)
    if isQBInput then
        options = convertFromQB(options)
    end

    local style = options.style or 'bar'
    local success = style == 'circle' and exports.ox_lib:progressCircle(options) or exports.ox_lib:progressBar(options)

    if cb then cb(success) end
    return success
end