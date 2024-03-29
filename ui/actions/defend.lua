local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local buffsState = ns.state.buffs.state
local character = ns.character
local characterState = ns.state.character.state
local consequences = ns.consequences
local constants = ns.constants
local environment = ns.state.environment
local feats = ns.resources.feats
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local CRIT_TYPES = constants.CRIT_TYPES
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local DEFENCE_TYPE_LABELS = constants.DEFENCE_TYPE_LABELS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

-- shared with melee save
-- action: String (defend, meleeSave, rangedSave)
--[[ options = {
    thresholdLabel: String
} ]]
ui.modules.actions.modules.defend.getSharedOptions = function(action, options)
    return {
        defenceType = {
            order = 0,
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
        defendThreshold = {
            order = 1,
            name = "Defend threshold",
            type = "range",
            desc = options.thresholdLabel,
            min = 1,
            softMax = 20,
            max = 100,
            step = 1,
            disabled = function()
                return rolls.state[action].defenceType.get() ~= DEFENCE_TYPES.THRESHOLD
            end,
            get = rolls.state[action].threshold.get,
            set = function(info, value)
                rolls.state[action].threshold.set(value)
            end
        },
        damageRisk = action ~= "rangedSave" and {
            order = 2,
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
        damageType = action ~= "rangedSave" and {
            order = 3,
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
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("defend", { thresholdLabel = "The minimum required roll to not take any damage" })

    local function shouldHideRoll()
        return not (rolls.state.defend.threshold.get() and rolls.state.defend.damageRisk.get())
    end

    return {
        name = ACTION_LABELS.defend,
        type = "group",
        order = options.order,
        args = {
            defenceType = sharedOptions.defenceType,
            defendThreshold = sharedOptions.defendThreshold,
            damageRisk = sharedOptions.damageRisk,
            damageType = sharedOptions.damageType,
            useHolyBulwark = ui.helpers.traitButton(TRAITS.HOLY_BULWARK, {
                order = 4,
                hidden = function()
                    local enemyId = environment.state.enemyId.get()
                    return not rules.traits.canUseHolyBulwark(enemyId) or not rolls.state.defend.damageRisk.get() or rolls.state.defend.defenceType.get() ~= DEFENCE_TYPES.THRESHOLD
                end,
                func = function()
                    consequences.useTrait(TRAITS.HOLY_BULWARK)(false)
                end,
            }),
            useRetaliateAndDecimate = ui.helpers.traitButton(TRAITS.RETALIATE_AND_DECIMATE, {
                order = 5,
                hidden = function()
                    return not character.hasTrait(TRAITS.RETALIATE_AND_DECIMATE) or not rolls.state.defend.damageRisk.get()
                end,
                width = "full",
            }),
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 6,
                hidden = function()
                    return shouldHideRoll() or not rules.defence.shouldShowPreRollUI()
                end,
                args = utils.merge(
                    ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 3, action = ACTIONS.defend }),
                    {
                        useApexProtector = ui.helpers.traitButton(TRAITS.APEX_PROTECTOR, {
                            order = 0,
                            checkBuff = true,
                        }),
                        apexProtectorActive = ui.helpers.traitActiveText(TRAITS.APEX_PROTECTOR, 0),
                        useAnqulansRedoubt = ui.helpers.traitButton(TRAITS.ANQULANS_REDOUBT, {
                            order = 1,
                            checkBuff = true,
                        }),
                        anqulansRedoubtActive = ui.helpers.traitActiveText(TRAITS.ANQULANS_REDOUBT, 1),
                        enableLivingBarricade = {
                            order = 2,
                            type = "execute",
                            name = COLOURS.FEATS.GENERIC .. "Enable " .. FEATS.LIVING_BARRICADE.name,
                            desc = FEATS.LIVING_BARRICADE.desc,
                            hidden = function()
                                return not character.hasFeat(FEATS.LIVING_BARRICADE) or buffsState.buffLookup.getFeatBuffs(FEATS.LIVING_BARRICADE)
                            end,
                            func = consequences.enableLivingBarricade,
                        },
                        livingBarricadeActive = {
                            order = 2,
                            type = "description",
                            name = COLOURS.FEATS.GENERIC .. FEATS.LIVING_BARRICADE.name .. " is active.",
                            hidden = function()
                                return not (character.hasFeat(FEATS.LIVING_BARRICADE) and buffsState.buffLookup.getFeatBuffs(FEATS.LIVING_BARRICADE))
                            end,
                        },
                        useWayOfTheStab = ui.helpers.traitButton(TRAITS.WAY_OF_THE_STAB, {
                            order = 3,
                            width = "full",
                            checkBuff = true,
                        }),
                        wayOfTheStabActive = ui.helpers.traitActiveText(TRAITS.WAY_OF_THE_STAB, 3),
                    }
                ),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 7,
                action = ACTIONS.defend,
                hidden = shouldHideRoll,
            }),
            defend = {
                order = 8,
                type = "group",
                name = ACTION_LABELS.defend,
                inline = true,
                hidden = function()
                    return not rolls.state.defend.currentRoll.get()
                end,
                args = {
                    actions_defence_brace = {
                        order = 0,
                        type = "range",
                        name = "Brace",
                        desc = "The amount of Brace charges to use. Each charge increases your Defence by 2.",
                        min = 0,
                        max = characterState.defence.numBraceCharges.get(),
                        step = 1,
                        hidden = function()
                            return not rules.defence.canUseBraceSystem()
                        end,
                        disabled = function()
                            return characterState.defence.numBraceCharges.get() == 0
                        end,
                        get = rolls.state.defend.numBraceCharges.get,
                        set = function(info, value)
                            rolls.state.defend.numBraceCharges.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("actions_defence_brace", {
                            max = characterState.defence.numBraceCharges.get
                        })
                    },
                    braceBottomMargin = {
                        order = 1,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not rules.defence.canUseBraceSystem()
                        end,
                    },
                    critType = {
                        order = 2,
                        type = "select",
                        name = "Crit effect",
                        width = 0.8,
                        hidden = function()
                            return not rolls.getDefence().isCrit
                        end,
                        values = {
                            [CRIT_TYPES.RETALIATE] = "Retaliate",
                            [CRIT_TYPES.PROTECTOR] = "Protector",
                        },
                        get = rolls.state.defend.critType.get,
                        set = function(info, value)
                            rolls.state.defend.critType.set(value)
                        end
                    },
                    critTypeMargin = {
                        order = 3,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not rolls.getDefence().isCrit
                        end,
                    },
                    result = {
                        order = 4,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            return actions.toString(ACTIONS.defend, rolls.getDefence())
                        end
                    },
                    defendValue = {
                        order = 5,
                        type = "description",
                        fontSize = "small",
                        hidden = function()
                            return not buffsState.buffLookup.getTraitBuffs(TRAITS.APEX_PROTECTOR)
                        end,
                        name = function()
                            return COLOURS.NOTE .. "Your total roll: " .. rolls.getDefence().defendValue
                        end
                    },
                    confirm = ui.helpers.confirmActionButton(ACTIONS.defend, rolls.getDefence, {
                        order = 6,
                        hideMsg = true,
                        func = function()
                            local defence = rolls.getDefence()
                            local hideMsg = defence.damageTaken > 0
                            consequences.confirmAction(ACTIONS.defend, rolls.getDefence(), hideMsg)
                        end
                    }),
                }
            },
            summary = {
                order = 9,
                type = "group",
                name = "Summary",
                inline = true,
                hidden = function()
                    return rolls.state.defend.defences.count() < 1
                end,
                args = {
                    totalDamage = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local msg = ""
                            local totalDamageTaken = 0
                            local totalDamagePrevented = 0

                            for i, defence in ipairs(rolls.state.defend.defences.get()) do
                                msg = msg .. COLOURS.NOTE .. ">|r " .. actions.toString(ACTIONS.defend, defence) .. "|r|n"
                                totalDamageTaken = totalDamageTaken + defence.damageTaken
                                totalDamagePrevented = totalDamagePrevented + defence.damagePrevented
                            end

                            if totalDamageTaken > 0 or totalDamagePrevented > 0 then
                                msg = msg .. COLOURS.NOTE .. "|nTotal:|r " .. totalDamageTaken .. " damage taken"

                                if totalDamagePrevented > 0 then
                                    msg = msg .. ", " .. totalDamagePrevented .. " damage prevented"
                                end

                                msg = msg .. "|n "
                            end

                            return msg
                        end,
                    },
                    reset = {
                        order = 1,
                        type = "execute",
                        width = 0.75,
                        name = "Clear",
                        func = function()
                            rolls.state.defend.defences.clear()
                        end,
                    }
                }
            },
--[[             postRoll = {
                order = 10,
                type = "group",
                name = "After rolling",
                inline = true,
                hidden = function()
                    return not rolls.state.defend.currentRoll.get() or rolls.getDefence().damageTaken > 0 or not rules.defence.shouldShowPostRollUI()
                end,
                args = {}
            } ]]
        },
    }
end
