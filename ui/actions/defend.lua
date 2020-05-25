local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local characterState = ns.state.character
local rolls = ns.state.rolls
local traits = ns.resources.traits
local ui = ns.ui

local TRAITS = traits.TRAITS
local state = characterState.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.defend.getOptions = function(options)
    return {
        name = "Defend",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            useBulwark = {
                order = 0,
                type = "toggle",
                name = COLOURS.TRAITS.GENERIC .. TRAITS.BULWARK.name,
                desc = TRAITS.BULWARK.desc,
                hidden = function()
                    return not character.hasTrait(TRAITS.BULWARK)
                end,
                disabled = function()
                    return state.featsAndTraits.numBulwarkCharges.get() == 0
                end,
                get = function()
                    return rolls.state.defend.useBulwark
                end,
                set = function (info, value)
                    rolls.state.defend.useBulwark = value
                end
            },
            damageTaken = {
                order = 1,
                type = "description",
                desc = "How much damage you take this turn",
                fontSize = "medium",
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
                order = 2,
                type = "execute",
                name = "Okay :(",
                desc = "Apply the stated damage to your character's HP",
                hidden = function()
                    return rolls.getDefence().damageTaken == 0
                end,
                func = function()
                    local defence = rolls.getDefence()
                    state.health.damage(defence.damageTaken)
                end
            }
        },
    }
end