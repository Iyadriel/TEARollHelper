local _, ns = ...

local buffsState = ns.state.buffs.state
local settings = ns.settings
local ui = ns.ui

local function debugView()
    return {
        order = 0,
        type = "group",
        name = "Buffs",
        inline = true,
        hidden = function()
            return not settings.debug.get()
        end,
        args = {
            statBuffs = {
                order = 1,
                type = "description",
                name = function()
                    local out = {
                        "Offence: ",
                        buffsState.buffs.offence.get(),
                        "|nDefence: ",
                        buffsState.buffs.defence.get(),
                        "|nSpirit: ",
                        buffsState.buffs.spirit.get(),
                        "|nStamina: ",
                        buffsState.buffs.stamina.get(),
                    }

                    return table.concat(out)
                end,
            }
        }
    }
end

ui.helpers.debugView = debugView