local _, ns = ...

local launchers = ns.launchers
local settings = ns.settings
local ui = ns.ui

ui.modules.config.modules.settings.getOptions = function()
    return {
        name = "Settings",
        type = "group",
        order = 2,
        cmdHidden = true,
        args = {
            minimapIcon = {
                order = 0,
                type = "toggle",
                name = "Minimap icon",
                desc = "If disabled, you can still use the /tea slash command to access the addon.",
                width = "full",
                get = function()
                    return not TEARollHelper.db.global.settings.minimapIcon.hide
                end,
                set = function(info, shown)
                    TEARollHelper.db.global.settings.minimapIcon.hide = not shown
                    launchers.setMinimapIconShown(shown)
                end
            },
            autoUpdateTRP = {
                order = 1,
                type = "toggle",
                name = "Auto update Total RP profile",
                desc = "When your character's state changes (e.g. when you lose HP), update your Total RP automatically.",
                width = "full",
                get = settings.autoUpdateTRP.get,
                set = function(info, value)
                    settings.autoUpdateTRP.set(value)
                    if value then
                        TEARollHelper.db.global.warningsSeen.updateTRP = true
                    end
                end,
                confirm = function()
                    local global = TEARollHelper.db.global
                    if not settings.autoUpdateTRP.get() and not global.warningsSeen.updateTRP then
                        return "This will allow this addon to overwrite any content you have set in your 'Currently' field."
                    end
                    return false
                end
            },
            debugMode = {
                order = 2,
                type = "toggle",
                name = "Debug mode",
                desc = "Don't touch this! I said don't.",
                width = "full",
                get = settings.debug.get,
                set = function(info, value)
                    settings.debug.set(value)
                end,
            }
        }
    }
end