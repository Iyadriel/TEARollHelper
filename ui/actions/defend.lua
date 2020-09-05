local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local TRAITS = traits.TRAITS

local state = characterState.state

-- shared with melee and ranged save
-- action: String (defend, meleeSave, rangedSave)
ui.modules.actions.modules.defend.getSharedOptions = function(action)
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
            get = rolls.state[action].threshold.get,
            set = function(info, value)
                rolls.state[action].threshold.set(value)
            end
        },
        damageRisk = action ~= "rangedSave" and {
            order = 1,
            name = "Damage risk",
            type = "range",
            desc = "How much damage is taken on a failed roll",
            min = 1,
            softMax = 20,
            max = 100,
            step = 1,
            get = rolls.state[action].damageRisk.get,
            set = function(info, value)
                rolls.state[action].damageRisk.set(value)
            end
        },
        damageType = action ~= "rangedSave" and {
            order = 2,
            name = "Damage type",
            type = "select",
            values = (function()
                local damageTypeOptions = {}
                for key, value in pairs(constants.DAMAGE_TYPES) do
                    damageTypeOptions[value] = constants.DAMAGE_TYPE_LABELS[key]
                end
                return damageTypeOptions
            end)(),
            hidden = function()
                return not rules.defence.shouldShowDamageType()
            end,
            get = rolls.state[action].damageType.get,
            set = function(info, value)
                rolls.state[action].damageType.set(value)
            end
        },
    }
end

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.defend.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("defend")

    local function shouldHideRoll()
        return not (rolls.state.defend.threshold.get() and rolls.state.defend.damageRisk.get())
    end

    return {
        name = ACTION_LABELS.defend,
        type = "group",
        order = options.order,
        args = {
            defendThreshold = sharedOptions.defendThreshold,
            damageType = sharedOptions.damageType,
            damageRisk = sharedOptions.damageRisk,
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 2,
                hidden = function()
                    return shouldHideRoll() or not rules.defence.shouldShowPreRollUI()
                end,
                args = utils.merge(
                    ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1 }),
                    {
                        useBulwark = {
                            order = 0,
                            type = "execute",
                            name = COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.BULWARK.name,
                            desc = TRAITS.BULWARK.desc,
                            hidden = function()
                                return not character.hasTrait(TRAITS.BULWARK) or state.buffLookup.getTraitBuffs(TRAITS.BULWARK)
                            end,
                            disabled = function()
                                return state.featsAndTraits.numTraitCharges.get(TRAITS.BULWARK.id) == 0
                            end,
                            func = consequences.useTrait(TRAITS.BULWARK),
                        },
                        bulwarkActive = {
                            order = 0,
                            type = "description",
                            name = COLOURS.TRAITS.GENERIC .. TRAITS.BULWARK.name .. " is active.",
                            hidden = function()
                                return not (character.hasTrait(TRAITS.BULWARK) and state.buffLookup.getTraitBuffs(TRAITS.BULWARK))
                            end,
                        },
                    }
                ),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 3,
                action = ACTIONS.defend,
                hidden = shouldHideRoll,
            }),
            defend = {
                order = 4,
                type = "group",
                name = ACTION_LABELS.defend,
                inline = true,
                hidden = function()
                    return not rolls.state.defend.currentRoll.get()
                end,
                args = {
                    damageTaken = {
                        order = 0,
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
                    confirm = {
                        order = 1,
                        type = "execute",
                        name = "Confirm",
                        desc = function()
                            if character.hasDefenceMastery() then
                                return "Apply the stated damage to your character's HP, or update your 'Damage prevented' counter."
                            end
                            return "Apply the stated damage to your character's HP."
                        end,
                        hidden = function()
                            return rolls.getDefence().damageTaken <= 0 and not character.hasDefenceMastery()
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