local _, ns = ...
local ui = ns.ui

ui.modules.config.modules = {
    character = {},
    settings = {},
}

ui.modules.config.getOptions = function()
    local options = {
        name = ui.modules.config.friendlyName,
        type = 'group',
        args = {
            turn = {
                order = 0,
                name = "Show turn window",
                type = "execute",
                func = function()
                    ui.openWindow(ui.modules.turn.name)
                end
            },
            character = {
                order = 1,
                name = "Character",
                type = "group",
                desc = "Character setup",
                cmdHidden = true,
                childGroups = "tab",
                args = {
                    character = ui.modules.config.modules.character.getOptions(),
                }
            },
            settings = ui.modules.config.modules.settings.getOptions(),
            config = {
                order = 3,
                name = "Show config UI",
                type = "execute",
                guiHidden = true,
                func = function()
                    ui.openWindow("TEARollHelper")
                end
            },
        }
    }

    return options
end