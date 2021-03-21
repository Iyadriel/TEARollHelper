local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local characterState = ns.state.character.state
local consequences = ns.consequences
local constants = ns.constants
local feats = ns.resources.feats
local rolls = ns.rolls
local rollState = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local CRIT_TYPES = constants.CRIT_TYPES
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local state = rollState.state

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
            hitRoll = ui.modules.turn.modules.roll.getOptions({
                order = 2,
                action = ACTIONS.attack,
                name = function()
                    local attack = rollState.getAttack()
                    if attack and attack.isSuccessful then
                        return COLOURS.SUCCESS .. "Hit roll"
                    end
                    return "Hit roll"
                end,
                hidden = function()
                    return shouldHideRoll()
                end,
            }),
            damageRoll = ui.modules.turn.modules.roll.getOptions({
                order = 3,
                action = ACTIONS.damage,
                name = "Damage roll",
                hidden = function()
                    return not state.attack.currentRoll.get() or not rollState.getAttack().isSuccessful
                end,
                hideMomentOfExcellence = true,
            }),
            attack = {
                order = 4,
                type = "group",
                name = ACTION_LABELS.attack,
                inline = true,
                hidden = function()
                    local shouldShow = state.attack.currentRoll.get() and (not rollState.getAttack().isSuccessful or state.damage.currentRoll.get())
                    return not shouldShow
                end,
                args = {
                    isAOE = {
                        order = 1,
                        type = "toggle",
                        name = "Damage multiple targets",
                        desc = "Spread your damage over multiple targets. This may affect how certain feats and traits behave.",
                        hidden = function()
                            return not rules.feats.canProc(FEATS.MERCY_FROM_PAIN)
                        end,
                        get = state.damage.isAOE.get,
                        set = function(info, value)
                            state.damage.isAOE.set(value)
                        end
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
                                get = state.damage.numGreaterHealSlots.get,
                                set = function(info, value)
                                    state.damage.numGreaterHealSlots.set(value)
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
                                    return not rules.healing.canUseTargetKOBonus() or state.damage.numGreaterHealSlots.get() < 1
                                end,
                                get = state.damage.targetIsKO.get,
                                set = function(info, value)
                                    state.damage.targetIsKO.set(value)
                                end,
                            },
                        }
                    },
                    dmgTopMargin = {
                        order = 3,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not (rules.feats.canProc(FEATS.MERCY_FROM_PAIN) or character.hasFeat(FEATS.PENANCE))
                        end,
                    },
                    critType = {
                        order = 4,
                        type = "select",
                        name = "Crit effect",
                        width = 0.8,
                        hidden = function()
                            return not rollState.getAttack().isCrit
                        end,
                        values = {
                            [CRIT_TYPES.VALUE_MOD] = "Double damage",
                            [CRIT_TYPES.MULTI_TARGET] = "Reap",
                        },
                        get = rollState.state.attack.critType.get,
                        set = function(info, value)
                            rollState.state.attack.critType.set(value)
                        end
                    },
                    critTypeMargin = {
                        order = 5,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not rollState.getAttack().isCrit
                        end,
                    },
                    dmg = {
                        order = 6,
                        type = "description",
                        desc = "How much damage you can deal to a target",
                        fontSize = "medium",
                        name = function()
                            local attack = rollState.getAttack()
                            return actions.toString(ACTIONS.attack, attack)
                        end
                    },
                    attackAgain = {
                        order = 7,
                        type = "execute",
                        name = COLOURS.FEATS.ADRENALINE .. "Attack again",
                        hidden = function()
                            return not rollState.getAttack().hasAdrenalineProc
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.attack, rollState.getAttack())
                            rolls.performRoll(ACTIONS.attack)
                        end
                    },
                    useBloodHarvest = {
                        order = 8,
                        type = "toggle",
                        width = "full",
                        name = function()
                            return COLOURS.FEATS.BLOOD_HARVEST .. "Use " .. FEATS.BLOOD_HARVEST.name
                        end,
                        desc = FEATS.BLOOD_HARVEST.desc,
                        hidden = function()
                            if rules.feats.canProc(FEATS.BLOOD_HARVEST) then
                                return rules.damage.getMaxBloodHarvestSlots() <= 0 or characterState.featsAndTraits.numBloodHarvestSlots.get() <= 0
                            end
                            return true
                        end,
                        get = function()
                            return state.damage.numBloodHarvestSlots.get() > 0
                        end,
                        set = function()
                            if state.damage.numBloodHarvestSlots.get() > 0 then
                                state.damage.numBloodHarvestSlots.set(0)
                            else
                                state.damage.numBloodHarvestSlots.set(1)
                            end
                        end,
                    },
                    useCriticalMass = ui.helpers.traitToggle(ACTIONS.damage, TRAITS.CRITICAL_MASS, {
                        order = 9,
                    }),
                    useFaultline = ui.helpers.traitToggle(ACTIONS.damage, TRAITS.FAULTLINE, {
                        order = 10,
                    }),
                    useReap = ui.helpers.traitToggle(ACTIONS.damage, TRAITS.REAP, {
                        order = 11,
                    }),
                    useVindication = ui.helpers.traitToggle(ACTIONS.damage, TRAITS.VINDICATION, {
                        order = 12,
                        name = function()
                            local vindication = rollState.getAttack().actions.damage.traits[TRAITS.VINDICATION.id]
                            if not vindication then return "" end
                            return COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.VINDICATION.name ..  ": " .. COLOURS.HEALING .. "Heal for " .. vindication.healingDone .. " HP"
                        end,
                    }),
                    confirm = {
                        order = 13,
                        type = "execute",
                        name = function()
                            local attack = rollState.getAttack()
                            local damage = attack.actions.damage
                            local colour

                            if damage.numBloodHarvestSlots > 0 then
                                colour = COLOURS.FEATS.BLOOD_HARVEST
                            elseif damage.hasMercyFromPainProc then
                                colour = COLOURS.FEATS.MERCY_FROM_PAIN
                            end

                            return colour and colour .. "Confirm" or "Confirm"
                        end,
                        desc = "Confirm that you perform the stated action, consuming any charges and buffs used.",
                        func = function()
                            consequences.confirmAction(ACTIONS.attack, rollState.getAttack())
                        end
                    },
                }
            },
            summary = {
                order = 5,
                type = "group",
                name = "Summary",
                inline = true,
                hidden = function()
                    return rollState.state.attack.attacks.count() < 1
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

                            for i, attack in ipairs(rollState.state.attack.attacks.get()) do
                                msg = msg .. COLOURS.NOTE .. ">|r " .. actions.toString(ACTIONS.attack, attack) .. "|r|n"

                                local damageAction = attack.actions.damage
                                totalDamage = totalDamage + damageAction.dmg
                                totalHealing = totalHealing + damageAction.amountHealed
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
                            rollState.state.attack.attacks.clear()
                        end,
                    }
                }
            }
        }
    }
end