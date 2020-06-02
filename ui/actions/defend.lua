local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local rolls = ns.state.rolls
local traits = ns.resources.traits
local ui = ns.ui

local TRAITS = traits.TRAITS
local state = characterState.state

-- shared with melee and ranged save
ui.modules.actions.modules.defend.getSharedOptions = function()
    return {
        defendThreshold = {
            order = 0,
            name = "Defend threshold",
            type = "range",
            desc = "The minimum required roll to not take any damage",
            min = 1,
            softMax = 20,
            max = 100,
            step = 1,
            get = rolls.state.defend.threshold.get,
            set = function(info, value)
                rolls.state.defend.threshold.set(value)
            end
        },
        damageRisk = {
            order = 1,
            name = "Damage risk",
            type = "range",
            desc = "How much damage you will take if you fail the roll",
            min = 1,
            softMax = 20,
            max = 100,
            step = 1,
            get = rolls.state.defend.damageRisk.get,
            set = function(info, value)
                rolls.state.defend.damageRisk.set(value)
            end
        },
    }
end

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.defend.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions()

    return {
        name = "Defend",
        type = "group",
        order = options.order,
        args = {
            defendThreshold = sharedOptions.defendThreshold,
            damageRisk = sharedOptions.damageRisk,
            roll = ui.modules.turn.modules.roll.getOptions({ order = 2, action = "defend" }),
            defend = {
                order = 3,
                type = "group",
                name = "Defend",
                inline = true,
                hidden = function()
                    return not rolls.state.defend.currentRoll.get()
                end,
                args = {
                    useBulwark = {
                        order = 3,
                        type = "toggle",
                        name = COLOURS.TRAITS.GENERIC .. TRAITS.BULWARK.name,
                        desc = TRAITS.BULWARK.desc,
                        hidden = function()
                            return not character.hasTrait(TRAITS.BULWARK)
                        end,
                        disabled = function()
                            return state.featsAndTraits.numBulwarkCharges.get() == 0
                        end,
                        get = rolls.state.defend.useBulwark.get,
                        set = function (info, value)
                            rolls.state.defend.useBulwark.set(value)
                        end
                    },
                    damageTaken = {
                        order = 4,
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
                        order = 5,
                        type = "execute",
                        name = "Okay :(",
                        desc = "Apply the stated damage to your character's HP",
                        hidden = function()
                            return rolls.getDefence().damageTaken == 0
                        end,
                        func = function()
                            consequences.confirmDefenceAction(rolls.getDefence())
                        end
                    }
                }
            },
        },
    }
end