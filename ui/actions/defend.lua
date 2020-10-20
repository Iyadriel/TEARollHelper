local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local buffsState = ns.state.buffs.state
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local feats = ns.resources.feats
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local DEFENCE_TYPE_LABELS = constants.DEFENCE_TYPE_LABELS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local state = characterState.state

-- shared with melee save
-- action: String (defend, meleeSave)
-- startOrder: Number
ui.modules.actions.modules.defend.getSharedOptions = function(action, startOrder)
    return {
        defenceType = {
            order = startOrder,
            type = "select",
            name = "Defence type",
            desc = "Select 'Threshold' for regular defence rolls, or 'Damage reduction' when the damage you take is x minus the result of your defence roll.",
            values = (function()
                local defenceTypeOptions = {}
                for key, value in pairs(DEFENCE_TYPES) do
                    defenceTypeOptions[value] = DEFENCE_TYPE_LABELS[key]
                end
                return defenceTypeOptions
            end)(),
            get = rolls.state[action].defenceType.get,
            set = function(info, value)
                rolls.state[action].defenceType.set(value)
            end
        },
        damageRisk = {
            order = startOrder + 2,
            name = "Damage risk",
            type = "range",
            min = 1,
            softMax = 30,
            max = 100,
            step = 1,
            get = rolls.state[action].damageRisk.get,
            set = function(info, value)
                rolls.state[action].damageRisk.set(value)
            end
        },
        damageType = {
            order = startOrder + 3,
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
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("defend", 0)

    local function shouldHideRoll()
        return not (rolls.state.defend.threshold.get() and rolls.state.defend.damageRisk.get())
    end

    return {
        name = ACTION_LABELS.defend,
        type = "group",
        order = options.order,
        args = {
            defenceType = sharedOptions.defenceType,
            defendThreshold = {
                order = 1,
                name = "Defend threshold",
                type = "range",
                desc = "The minimum required roll to not take any damage",
                min = 1,
                softMax = 20,
                max = 100,
                step = 1,
                disabled = function()
                    return rolls.state.defend.defenceType.get() ~= DEFENCE_TYPES.THRESHOLD
                end,
                get = rolls.state.defend.threshold.get,
                set = function(info, value)
                    rolls.state.defend.threshold.set(value)
                end
            },
            damageRisk = sharedOptions.damageRisk,
            damageType = sharedOptions.damageType,
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 4,
                hidden = function()
                    return shouldHideRoll() or not rules.defence.shouldShowPreRollUI()
                end,
                args = utils.merge(
                    ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1 }),
                    {
                        useBulwark = ui.helpers.traitButton(TRAITS.BULWARK, {
                            order = 0,
                            checkBuff = true,
                        }),
                        bulwarkActive = {
                            order = 0,
                            type = "description",
                            name = COLOURS.TRAITS.GENERIC .. TRAITS.BULWARK.name .. " is active.",
                            hidden = function()
                                return not (character.hasTrait(TRAITS.BULWARK) and buffsState.buffLookup.getTraitBuffs(TRAITS.BULWARK))
                            end,
                        },
                        enableLivingBarricade = {
                            order = 1,
                            type = "execute",
                            name = COLOURS.FEATS.GENERIC .. "Enable " .. FEATS.LIVING_BARRICADE.name,
                            desc = FEATS.LIVING_BARRICADE.desc,
                            hidden = function()
                                return not character.hasFeat(FEATS.LIVING_BARRICADE) or buffsState.buffLookup.getFeatBuff(FEATS.LIVING_BARRICADE)
                            end,
                            func = consequences.enableLivingBarricade,
                        },
                        livingBarricadeActive = {
                            order = 1,
                            type = "description",
                            name = COLOURS.FEATS.GENERIC .. FEATS.LIVING_BARRICADE.name .. " is active.",
                            hidden = function()
                                return not (character.hasFeat(FEATS.LIVING_BARRICADE) and buffsState.buffLookup.getFeatBuff(FEATS.LIVING_BARRICADE))
                            end,
                        },
                    }
                ),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 5,
                action = ACTIONS.defend,
                hidden = shouldHideRoll,
            }),
            defend = {
                order = 6,
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
                            return actions.toString(ACTIONS.defend, rolls.getDefence())
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
                            local defence = rolls.getDefence()
                            return defence.damageTaken <= 0 and defence.damagePrevented <= 0
                        end,
                        func = function()
                            local defence = rolls.getDefence()
                            local hideMsg = defence.damageTaken > 0
                            consequences.confirmAction(ACTIONS.defend, rolls.getDefence(), hideMsg)
                        end
                    }
                }
            },
            postRoll = {
                order = 7,
                type = "group",
                name = "After rolling",
                inline = true,
                hidden = function()
                    return not rolls.state.defend.currentRoll.get() or rolls.getDefence().damageTaken > 0 or not rules.defence.shouldShowPostRollUI()
                end,
                args = {
                    useEmpoweredBlades = {
                        order = 0,
                        type = "execute",
                        width = "full",
                        name = COLOURS.TRAITS.EMPOWERED_BLADES .. "Use " .. TRAITS.EMPOWERED_BLADES.name,
                        desc = TRAITS.EMPOWERED_BLADES.desc,
                        hidden = function()
                            return not rolls.getDefence().empoweredBladesEnabled
                        end,
                        disabled = function()
                            return state.featsAndTraits.numTraitCharges.get(TRAITS.EMPOWERED_BLADES.id) == 0
                        end,
                        func = function()
                            consequences.useTrait(TRAITS.EMPOWERED_BLADES)(rolls.getDefence())
                        end,
                    },
                }
            }
        },
    }
end