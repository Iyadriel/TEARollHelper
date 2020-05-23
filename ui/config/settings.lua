local _, ns = ...

local launchers = ns.launchers
local ui = ns.ui

ui.modules.config.modules.settings.getOptions = function()
    return {
        name = "Settings",
        type = "group",
        order = 2,
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
                order = 0,
                type = "toggle",
                name = "Auto update Total RP profile",
                desc = "When your character's state changes (e.g. when you lose HP), update your Total RP automatically.",
                width = "full",
                get = function()
                    return TEARollHelper.db.global.settings.autoUpdateTRP
                end,
                set = function(info, value)
                    TEARollHelper.db.global.settings.autoUpdateTRP = value
                end
            }
        }
    }
end