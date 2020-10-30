local _, ns = ...

local buffsState = ns.state.buffs.state
local settings = ns.settings
local ui = ns.ui

local function debugView()
    return {
        order = 0,
        type = "group",
        name = "Debug",
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
                        "Offence buff: ",
                        buffsState.buffs.offence.get(),
                        "|nDefence buff: ",
                        buffsState.buffs.defence.get(),
                        "|nSpirit buff: ",
                        buffsState.buffs.spirit.get(),
                        "|nStamina buff: ",
                        buffsState.buffs.stamina.get(),
                    }

                    return table.concat(out)
                end,
            }
        }
    }
end

ui.helpers.debugView = debugView