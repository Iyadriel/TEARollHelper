local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local characterState = ns.state.character.state
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
local TURN_TYPES = constants.TURN_TYPES

local state = rolls.state

--[[ local options = {
    order: Number
    outOfCombat: Boolean,
    turnTypeID: String,
} ]]
ui.modules.actions.modules.healing.getOptions = function(options)
    local shouldShowPlayerTurnOptions = options.turnTypeID == TURN_TYPES.PLAYER.id
    local preRollArgs = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1, action = ACTIONS.healing, actionArgs = { options.outOfCombat } })

    if shouldShowPlayerTurnOptions then
        preRollArgs = utils.merge(preRollArgs, ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 0 }))
    end

    return {
        name = ACTION_LABELS.healing,
        type = "group",
        order = options.order,
        hidden = function()
            return not character.canHeal(options.outOfCombat)
        end,
        args = {
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 0,
                hidden = function()
                    return not rules.healing.shouldShowPreRollUI(options.turnTypeID)
                end,
                args = preRollArgs,
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 1,
                action = ACTIONS.healing,
            }),
            heal = {
                order = 2,
                type = "group",
                name = ACTION_LABELS.healing,
                inline = true,
                hidden = function()
                    return not state.healing.currentRoll.get()
                end,
                args = {
                    actions_healing_greaterHeals = {
                        order = 1,
                        type = "range",
                        name = "Greater Heals",
                        desc = "The amount of Greater Heals to use.",
                        min = 0,
                        max = characterState.healing.numGreaterHealSlots.get(),
                        step = 1,
                        hidden = function()
                            return rules.healing.getMaxGreaterHealSlots() == 0
                        end,
                        disabled = function()
                            return characterState.healing.numGreaterHealSlots.get() == 0
                        end,
                        get = state.healing.numGreaterHealSlots.get,
                        set = function(info, value)
                            state.healing.numGreaterHealSlots.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("actions_healing_greaterHeals", {
                            max = characterState.healing.numGreaterHealSlots.get
                        })
                    },
                    targetIsKO = {
                        order = 2,
                        type = "toggle",
                        name = "Target is unconscious",
                        desc = COLOURS.MASTERY .. "Your Spirit mastery increases healing done to KO'd targets by +3.",
                        hidden = function()
                            return not rules.healing.canUseTargetKOBonus()
                        end,
                        get = state.healing.targetIsKO.get,
                        set = function(info, value)
                            state.healing.targetIsKO.set(value)
                        end,
                    },
                    healing = {
                        type = "description",
                        desc = "How much you can heal for",
                        fontSize = "medium",
                        order = 3,
                        name = function()
                            local healing = rolls.getHealing(options.outOfCombat)
                            local msg = rules.healing.getMaxGreaterHealSlots() > 0 and " |n" or "" -- Only show spacing if greater heals are shown. Dirty hack

                            return msg .. actions.toString(ACTIONS.healing, healing)
                        end
                    },
                    useLifePulse = ui.helpers.traitToggle(
                        ACTIONS.healing,
                        TRAITS.LIFE_PULSE, {
                            order = 4,
                            actionArgs = { options.outOfCombat },
                        }
                    ),
                    confirm = {
                        order = 5,
                        type = "execute",
                        name = function()
                            local heal = rolls.getHealing(options.outOfCombat)
                            local colour

                            if heal.hasChaplainOfViolenceProc then
                                colour = COLOURS.FEATS.CHAPLAIN_OF_VIOLENCE
                            end

                            return colour and colour .. "Confirm" or "Confirm"
                        end,
                        desc = "Confirm that you perform the stated action, and consume any charges used.",
                        hidden = function()
                            return rolls.getHealing(options.outOfCombat).amountHealed <= 0
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.healing, rolls.getHealing(options.outOfCombat))
                        end
                    },
                    remainingHeals = {
                        order = 6,
                        type = "description",
                        name = function()
                            if rolls.getHealing(options.outOfCombat).numGreaterHealSlots > 0 then
                                return COLOURS.NOTE .. " |nUsing Greater Heals, there is no limit to how often you can heal out of combat."
                            end

                            return COLOURS.NOTE .. " |nRemaining regular heals out of combat: " .. characterState.healing.remainingOutOfCombatHeals.get()
                        end,
                        hidden = function()
                            return not options.outOfCombat or rolls.getHealing(options.outOfCombat).amountHealed <= 0
                        end,
                    },
                }
            },
            summary = {
                order = 3,
                type = "group",
                name = "Summary",
                inline = true,
                hidden = function()
                    return rolls.state.healing.heals.count() < 1
                end,
                args = {
                    totalHealing = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local msg = ""
                            local totalHealing = 0

                            for _, heal in ipairs(rolls.state.healing.heals.get()) do
                                msg = msg .. COLOURS.NOTE .. ">|r " .. actions.toString(ACTIONS.healing, heal) .. "|r|n"
                                totalHealing = totalHealing + heal.amountHealed
                            end

                            msg = msg .. COLOURS.NOTE .. "|nTotal:|r " .. totalHealing .. " healing|n "

                            return msg
                        end,
                    },
                    reset = {
                        order = 1,
                        type = "execute",
                        width = 0.75,
                        name = "Clear",
                        func = function()
                            rolls.state.healing.heals.clear()
                        end,
                    }
                }
            },
            removeWounds = {
                order = 4,
                type = "group",
                inline = true,
                name = "Remove critical wounds",
                hidden = function()
                    local shown = character.hasTrait(TRAITS.GREATER_RESTORATION)

                    if not shown then
                        local cost = rules.criticalWounds.getNumGreaterHealSlotsToRemoveCriticalWound()
                        shown = cost <= rules.healing.getMaxGreaterHealSlots()
                    end

                    return not shown
                end,
                args = {
                    removeWound = {
                        order = 0,
                        type = "execute",
                        name = "Remove critical wound",
                        desc = function()
                            local cost = rules.criticalWounds.getNumGreaterHealSlotsToRemoveCriticalWound()
                            return "Spend " .. cost .. " Greater Heal slot(s) to remove a critical wound from yourself or someone else."
                        end,
                        disabled = function()
                            local cost = rules.criticalWounds.getNumGreaterHealSlotsToRemoveCriticalWound()
                            return characterState.healing.numGreaterHealSlots.get() < cost
                        end,
                        hidden = function()
                            local cost = rules.criticalWounds.getNumGreaterHealSlotsToRemoveCriticalWound()
                            return rules.healing.getMaxGreaterHealSlots() < cost
                        end,
                        func = consequences.removeCriticalWoundWithGreaterHealSlots,
                    },
                    useGreaterRestoration = ui.helpers.traitButton(TRAITS.GREATER_RESTORATION, {
                        order = 1,
                        checkBuff = true,
                    }),
                }
            }
        }
    }
end