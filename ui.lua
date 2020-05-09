local _, ns = ...
local ui = ns.ui

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

ui.modules = {}

ui.getOptions = function()
    return {
        name = "TeaRollHelper",
        handler = TeaRollHelper,
        type = 'group',
        args = {
            roll = ui.modules.roll,
            character = {
                name = "Character",
                type = "group",
                desc = "Character setup",
                cmdInline = true,
                childGroups = "tab",
                order = 1,
                args = {
                    character = ui.modules.character,
                    buff = ui.modules.buffs
                }
            },
            rolls = ui.modules.rolls,
            -- this group just serves to have a nice header at the bottom of the cmd printout
            config = {
                name = "config",
                type = "group",
                desc = "Configuration",
                guiHidden = true,
                cmdInline = true,
                order = 2,
                args = {
                    config = {
                        name = "config",
                        type = "execute",
                        desc = "Show config UI",
                        guiHidden = true,
                        order = 0,
                        func = function()
                            AceConfigDialog:Open("TeaRollHelper")
                        end
                    },
                }
            }
        }
    }
end