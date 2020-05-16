local _, ns = ...
local ui = ns.ui

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

ui.modules.config.modules = {
    character = {},
    settings = {},
}

ui.modules.config.getOptions = function()
    local options = {
        name = ui.constants.FRIENDLY_NAME,
        type = 'group',
        args = {
            roll = {
                name = "Show roll window",
                type = "execute",
                order = 0,
                func = function()
                    AceConfigDialog:Open(ui.modules.rolls.name)
                end
            },
            character = {
                name = "Character",
                type = "group",
                desc = "Character setup",
                cmdInline = true,
                childGroups = "tab",
                order = 1,
                args = {
                    buff = ui.modules.buffs.getOptions(),
                    character = ui.modules.config.modules.character.getOptions(),
                }
            },
            settings = ui.modules.config.modules.settings.getOptions(),
            -- this group just serves to have a nice header at the bottom of the cmd printout
            config = {
                name = "config",
                type = "group",
                desc = "Configuration",
                guiHidden = true,
                cmdInline = true,
                order = 3,
                args = {
                    config = {
                        name = "Show config UI",
                        type = "execute",
                        guiHidden = true,
                        order = 0,
                        func = function()
                            AceConfigDialog:Open("TEARollHelper")
                        end
                    },
                }
            }
        }
    }

    -- We want this in the cmd line and in the roll window, but not the config window, so disable it here.
    options.args.character.args.buff.guiHidden = true

    return options
end