local Config = require "config.config"

Modules.Client.TextUI = {}

--- Displays a TextUI hint on screen using the configured draw-text resource.
--- Supports: jg-textui, ox_lib, okokTextUI, ps-ui, qb-core.
--- The active system is determined by `Config.DrawText` ("auto" auto-detects).
--- Throws an error if no supported TextUI system is found.
---@param text string The text content to display in the TextUI element.
---@return nil
function Modules.Client.TextUI.ShowTextUI(text)
    if (Config.DrawText == "auto" and GetResourceState("jg-textui") == "started") or Config.DrawText == "jg-textui" then
        exports["jg-textui"]:DrawText(text)
    elseif (Config.DrawText == "auto" and GetResourceState("ox_lib") == "started") or Config.DrawText == "ox_lib" then
        exports["ox_lib"]:showTextUI(text, {
            position = "left-center"
        })
    elseif (Config.DrawText == "auto" and GetResourceState("okokTextUI") == "started") or Config.DrawText == "okokTextUI" then
        exports["okokTextUI"]:Open(text, "lightblue", "left")
    elseif (Config.DrawText == "auto" and GetResourceState("ps-ui") == "started") or Config.DrawText == "ps-ui" then
        exports["ps-ui"]:DisplayText(text, "primary")
    elseif GetResourceState('qb-core') ~= 'started' and GetResourceState('qbx_core') == 'started' then
        exports["qb-core"]:DrawText(text)
    else
        error("You do not have a TextUI system set up!")
    end
end

--- Hides the currently visible TextUI element using the configured draw-text resource.
--- Supports: jg-textui, ox_lib, okokTextUI, ps-ui, qb-core.
--- The active system is determined by `Config.DrawText` ("auto" auto-detects).
--- Throws an error if no supported TextUI system is found.
---@return nil
function Modules.Client.TextUI.HideTextUI()
    if (Config.DrawText == "auto" and GetResourceState("jg-textui") == "started") or Config.DrawText == "jg-textui" then
        exports["jg-textui"]:HideText()
    elseif (Config.DrawText == "auto" and GetResourceState("ox_lib") == "started") or Config.DrawText == "ox_lib" then
        exports["ox_lib"]:hideTextUI()
    elseif (Config.DrawText == "auto" and GetResourceState("okokTextUI") == "started") or Config.DrawText == "okokTextUI" then
        exports["okokTextUI"]:Close()
    elseif (Config.DrawText == "auto" and GetResourceState("ps-ui") == "started") or Config.DrawText == "ps-ui" then
        exports["ps-ui"]:HideText()
    elseif GetResourceState('qb-core') ~= 'started' and GetResourceState('qbx_core') == 'started' then
        exports["qb-core"]:HideText()
    else
        error("You do not have a TextUI system set up!")
    end
end