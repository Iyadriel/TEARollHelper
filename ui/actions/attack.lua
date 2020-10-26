local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local buffsState = ns.state.buffs.state
local character = ns.character
local characterState = ns.state.character.state
local consequences = ns.consequences
local constants = ns.constants
local feats = ns.resources.feats
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local turns = ns.turns
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
            ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 1 }),
            ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 2 }),
            {
                useCalamityGambit = ui.helpers.traitButton(TRAITS.CALAMITY_GAMBIT, {
                    order = 0,
                    checkBuff = true,
                }),
                calamityGambitActive = {
                    order = 0,
                    type = "description",
                    name = COLOURS.TRAITS.GENERIC .. TRAITS.CALAMITY_GAMBIT.name .. " is active.",
                    hidden = function()
                        return not (character.hasTrait(TRAITS.CALAMITY_GAMBIT) and buffsState.buffLookup.getTraitBuffs(TRAITS.CALAMITY_GAMBIT))
                    end,
                },
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
                    dmgTopMargin = {
                        order = 3,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not (rules.offence.canUseBloodHarvest() or rules.offence.canProcMercyFromPain())
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
                    confirm = {
                        order = 5,
                        type = "execute",
                        name = function()
                            local colour
                            if character.hasFeat(FEATS.BLOOD_HARVEST) then
                                colour = COLOURS.FEATS.BLOOD_HARVEST
                            elseif character.hasFeat(FEATS.MERCY_FROM_PAIN) then
                                colour = COLOURS.FEATS.MERCY_FROM_PAIN
                            end
                            return colour and colour .. "Confirm" or "Confirm"
                        end,
                        desc = "Confirm that you perform the stated action, and consume any charges used.",
                        hidden = function()
                            local attack = rolls.getAttack()
                            local shouldShow = false

                            if character.hasFeat(FEATS.ADRENALINE) then
                                shouldShow = rolls.state.attack.attacks.count() > 0 and attack.dmg > 0
                            else
                                shouldShow = attack.numBloodHarvestSlots > 0 or attack.hasMercyFromPainProc
                            end

                            return not shouldShow
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.attack, rolls.getAttack())
                        end
                    },
                    attackAgain = {
                        order = 6,
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

                            turns.setAction(action)
                            turns.roll(rollMode, rollModeMod, false)
                        end
                    },
                }
            },
            postRoll = {
                order = 4,
                type = "group",
                name = "After rolling",
                inline = true,
                hidden = function()
                    return not state.attack.currentRoll.get() or not (rolls.getAttack().dmg > 0) or not rules.offence.shouldShowPostRollUI()
                end,
                args = {
                    useFaultline = ui.helpers.traitButton(TRAITS.FAULTLINE, { order = 0 }),
                    useShatterSoul = ui.helpers.traitButton(TRAITS.SHATTER_SOUL, {
                        order = 1,
                        hidden = function()
                            return not rolls.getAttack().shatterSoulEnabled
                        end,
                    }),
                    useVindication = {
                        order = 2,
                        type = "execute",
                        width = "full",
                        name = function()
                            return COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.VINDICATION.name ..  ": " .. COLOURS.HEALING .. "Heal for " .. rolls.getAttack().vindicationHealing .. " HP"
                        end,
                        desc = TRAITS.VINDICATION.desc,
                        hidden = function()
                            return not rolls.getAttack().hasVindicationProc
                        end,
                        disabled = function()
                            return characterState.featsAndTraits.numTraitCharges.get(TRAITS.VINDICATION.id) == 0
                        end,
                        func = consequences.useTrait(TRAITS.VINDICATION),
                    }
                }
            },
            summary = {
                order = 5,
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

                            for i, attack in ipairs(rolls.state.attack.attacks.get()) do
                                msg = msg .. COLOURS.NOTE .. ">|r " .. actions.toString(ACTIONS.attack, attack) .. "|n"
                                totalDamage = totalDamage + attack.dmg
                            end

                            msg = msg .. COLOURS.NOTE .. "|nTotal:|r " .. totalDamage .. " damage|n "

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