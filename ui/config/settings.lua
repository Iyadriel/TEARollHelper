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
                name = "Minimap icon",
                type = "toggle",
                desc = "If disabled, you can still use the /tea slash command to access the addon.",
                get = function()
                    return not TEARollHelper.db.global.settings.minimapIcon.hide
                end,
                set = function(info, shown)
                    TEARollHelper.db.global.settings.minimapIcon.hide = not shown
                    launchers.setMinimapIconShown(shown)
                end
            }
        }
    }
end