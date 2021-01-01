local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local characterState = ns.state.character.state
local consequences = ns.consequences
local constants = ns.constants
local feats = ns.resources.feats
local rollHandler = ns.rollHandler
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.attack.getOptions = function(options)
    local function shouldHideRoll()
        return not state.attack.threshold.get()
    end

    local preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
        order = 1,
        hidden = function()
            return shouldHideRoll() or not rules.offence.shouldShowPreRollUI()
        end,
        args = utils.merge(
            ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 0 }),
            ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1, action = ACTIONS.attack }),
            {
                useVeseerasIre = ui.helpers.traitButton(TRAITS.VESEERAS_IRE, {
                    order = 2,
                    checkBuff = true,
                }),
                veseerasIreActive = ui.helpers.traitActiveText(TRAITS.VESEERAS_IRE, 3),
            }
        ),
    })

    return {
        name = ACTION_LABELS.attack,
        type = "group",
        order = options.order,
        args = {
            attackThreshold = {
                order = 0,
                name = "Attack threshold",
                type = "range",
                desc = "The minimum required roll to hit the target",
                min = 1,
                softMax = 20,
                max = 100,
                step = 1,
                get = state.attack.threshold.get,
                set = function(info, value)
                    state.attack.threshold.set(value)
                end
            },
            preRoll = preRoll,
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 2,
                action = ACTIONS.attack,
                hidden = shouldHideRoll,
            }),
            attack = {
                order = 3,
                type = "group",
                name = ACTION_LABELS.attack,
                inline = true,
                hidden = function()
                    return not state.attack.currentRoll.get()
                end,
                args = {
                    isAOE = {
                        order = 1,
                        type = "toggle",
                        name = "Damage multiple targets",
                        desc = "Spread your damage over multiple targets. This may affect how certain feats and traits behave.",
                        hidden = function()
                            return not rules.offence.canProcMercyFromPain()
                        end,
                        get = state.attack.isAOE.get,
                        set = function(info, value)
                            state.attack.isAOE.set(value)
                        end
                    },
                    actions_attack_bloodHarvest = {
                        order = 2,
                        type = "range",
                        name = COLOURS.FEATS.BLOOD_HARVEST .. FEATS.BLOOD_HARVEST.name,
                        desc = "The amount of Blood Harvest slots to use.",
                        min = 0,
                        max = characterState.featsAndTraits.numBloodHarvestSlots.get(),
                        step = 1,
                        hidden = function()
                            return not rules.offence.canUseBloodHarvest()
                        end,
                        disabled = function()
                            return rules.offence.getMaxBloodHarvestSlots() == 0 or characterState.featsAndTraits.numBloodHarvestSlots.get() == 0
                        end,
                        get = state.attack.numBloodHarvestSlots.get,
                        set = function(info, value)
                            state.attack.numBloodHarvestSlots.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("actions_attack_bloodHarvest", {
                            max = characterState.featsAndTraits.numBloodHarvestSlots.get
                        })
                    },
                    penance = {
                        order = 2,
                        type = "group",
                        name = "Penance",
                        hidden = function()
                            return not character.hasFeat(FEATS.PENANCE) or rules.healing.getMaxGreaterHealSlots() == 0
                        end,
                        args = {
                            actions_attack_greaterHeals = {
                                order = 0,
                                type = "range",
                                name = "Greater Heals",
                                desc = "The amount of Greater Heals to use.",
                                min = 0,
                                max = characterState.healing.numGreaterHealSlots.get(),
                                step = 1,
                                disabled = function()
                                    return characterState.healing.numGreaterHealSlots.get() == 0
                                end,
                                get = state.attack.numGreaterHealSlots.get,
                                set = function(info, value)
                                    state.attack.numGreaterHealSlots.set(value)
                                end,
                                dialogControl = TEARollHelper:CreateCustomSlider("actions_attack_greaterHeals", {
                                    max = characterState.healing.numGreaterHealSlots.get
                                })
                            },
                            targetIsKO = {
                                order = 1,
                                type = "toggle",
                                name = "Heal target is unconscious",
                                desc = COLOURS.MASTERY .. "Your Spirit mastery increases healing done to KO'd targets by +3.",
                                hidden = function()
                                    return not rules.healing.canUseTargetKOBonus() or state.attack.numGreaterHealSlots.get() < 1
                                end,
                                get = state.attack.targetIsKO.get,
                                set = function(info, value)
                                    state.attack.targetIsKO.set(value)
                                end,
                            },
                        }
                    },
                    dmgTopMargin = {
                        order = 3,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not (rules.offence.canUseBloodHarvest() or rules.offence.canProcMercyFromPain() or character.hasFeat(FEATS.PENANCE))
                        end,
                    },
                    dmg = {
                        order = 4,
                        type = "description",
                        desc = "How much damage you can deal to a target",
                        fontSize = "medium",
                        name = function()
                            local attack = rolls.getAttack()
                            return actions.toString(ACTIONS.attack, attack)
                        end
                    },
                    attackAgain = {
                        order = 5,
                        type = "execute",
                        name = COLOURS.FEATS.ADRENALINE .. "Attack again",
                        hidden = function()
                            return not rolls.getAttack().hasAdrenalineProc
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.attack, rolls.getAttack())

                            local action = ACTIONS.attack

                            local rollMode = state[action].rollMode.get()
                            local rollModeMod = rolls.getRollModeModifier(action, TURN_TYPES.PLAYER.id)

                            rollHandler.setAction(action)
                            rollHandler.roll(rollMode, rollModeMod, false)
                        end
                    },
                    useCriticalMass = ui.helpers.traitToggle(ACTIONS.attack, TRAITS.CRITICAL_MASS, {
                        order = 6,
                    }),
                    useFaultline = ui.helpers.traitToggle(ACTIONS.attack, TRAITS.FAULTLINE, {
                        order = 7,
                    }),
                    useReap = ui.helpers.traitToggle(ACTIONS.attack, TRAITS.REAP, {
                        order = 8,
                    }),
                    useShatterSoul = ui.helpers.traitToggle(ACTIONS.attack, TRAITS.SHATTER_SOUL, {
                        order = 9,
                    }),
                    useVindication = ui.helpers.traitToggle(ACTIONS.attack, TRAITS.VINDICATION, {
                        order = 10,
                        name = function()
                            return COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.VINDICATION.name ..  ": " .. COLOURS.HEALING .. "Heal for " .. rolls.getAttack().traits[TRAITS.VINDICATION.id].healingDone .. " HP"
                        end,
                    }),
                    confirm = {
                        order = 11,
                        type = "execute",
                        name = function()
                            local attack = rolls.getAttack()
                            local colour

                            if attack.numBloodHarvestSlots > 0 then
                                colour = COLOURS.FEATS.BLOOD_HARVEST
                            elseif attack.hasMercyFromPainProc then
                                colour = COLOURS.FEATS.MERCY_FROM_PAIN
                            end
                            return colour and colour .. "Confirm" or "Confirm"
                        end,
                        desc = "Confirm that you perform the stated action, consuming any charges and buffs used.",
                        hidden = function()
                            local attack = rolls.getAttack()
                            local shouldShow = attack.dmg > 0

                            return not shouldShow
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.attack, rolls.getAttack())
                        end
                    },
                }
            },
--[[             postRoll = {
                order = 4,
                type = "group",
                name = "After rolling",
                inline = true,
                hidden = function()
                    return not state.attack.currentRoll.get() or not (rolls.getAttack().dmg > 0) or not rules.offence.shouldShowPostRollUI()
                end,
                args = {
                }
            }, ]]
            summary = {
                order = 4,
                type = "group",
                name = "Summary",
                inline = true,
                hidden = function()
                    return rolls.state.attack.attacks.count() < 1
                end,
                args = {
                    totalDamage = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local msg = ""
                            local totalDamage = 0
                            local totalHealing = 0

                            for i, attack in ipairs(rolls.state.attack.attacks.get()) do
                                msg = msg .. COLOURS.NOTE .. ">|r " .. actions.toString(ACTIONS.attack, attack) .. "|r|n"

                                totalDamage = totalDamage + attack.dmg
                                totalHealing = totalHealing + attack.amountHealed
                            end

                            msg = msg .. COLOURS.NOTE .. "|nTotal:|r " .. totalDamage .. " damage"

                            if totalHealing > 0 then
                                msg = msg .. ", " .. totalHealing .. " healing|n "
                            end

                            msg = msg .. "|n "

                            return msg
                        end,
                    },
                    reset = {
                        order = 1,
                        type = "execute",
                        width = 0.75,
                        name = "Clear",
                        func = function()
                            rolls.state.attack.attacks.clear()
                        end,
                    }
                }
            }
        }
    }
end