local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local rolls = ns.state.rolls
local characterState = ns.state.character
local ui = ns.ui

local state = characterState.state

--[[ local options = {
    order: Number
} ]]
ui.modules.rolls.modules.defend.getOptions = function(options)
    return {
        name = "Defend",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            damageTaken = {
                type = "description",
                desc = "How much damage you take this turn",
                fontSize = "medium",
                order = 0,
                name = function()
                    local defence = rolls.getDefence()

                    if defence.damageTaken > 0 then
                        return COLOURS.DAMAGE .. "You take " .. tostring(defence.damageTaken) .. " damage."
                    else
                        local msg = "Safe! You don't take damage this turn."
                        if defence.canRetaliate then
                            msg = msg .. COLOURS.CRITICAL .. "\nRETALIATE!|r You can deal "..defence.retaliateDmg.." damage to your attacker!"
                        end
                        return msg
                    end
                end
            },
            okay = {
                type = "execute",
                name = "Okay :(",
                order = 1,
                func = function()
                    local defence = rolls.getDefence()
                    state.health.subtract(defence.damageTaken, true)
                end
            }
        },
    }
end