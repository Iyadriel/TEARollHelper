local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local characterState = ns.state.character.state
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
local FEATS = feats.FEATS
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
    local preRollArgs = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1 })

    if shouldShowPlayerTurnOptions then
        preRollArgs = utils.merge(preRollArgs, ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 0 }))
    end

    return {
        name = ACTION_LABELS.healing,
        type = "group",
        order = options.order,
        hidden = function()
            return not rules.healing.canHeal()
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
                    confirm = {
                        order = 4,
                        type = "execute",
                        name = "Confirm",
                        desc = "Confirm that you perform the stated action, and consume any charges used.",
                        hidden = function()
                            return rolls.getHealing(options.outOfCombat).amountHealed <= 0
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.healing, rolls.getHealing(options.outOfCombat))
                        end
                    },
                    outOfCombatNote = {
                        order = 5,
                        type = "description",
                        name = function()
                            local msg = COLOURS.NOTE .. " |nOut of combat, you can perform "
                            if character.hasFeat(FEATS.MEDIC) then
                                msg = msg .. COLOURS.FEATS.GENERIC .. rules.healing.calculateNumHealsAllowedOutOfCombat() .. " regular heals" .. COLOURS.NOTE
                            else
                                msg = msg .. rules.healing.calculateNumHealsAllowedOutOfCombat() .. " regular heals"
                            end
                            msg = msg .. " (refreshes after combat ends), or spend as many Greater Heal slots as you want (you can roll every time you spend slots)."
                            return msg
                        end,
                        hidden = not options.outOfCombat,
                    },
                }
            },
            postRoll = {
                order = 3,
                type = "group",
                name = "After rolling",
                inline = true,
                hidden = function()
                    return not state.healing.currentRoll.get() or not (rolls.getHealing(options.outOfCombat).amountHealed > 0) or not rules.healing.shouldShowPostRollUI()
                end,
                args = {
                    useLifePulse = {
                        order = 2,
                        type = "execute",
                        width = "full",
                        name = function()
                            return COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.LIFE_PULSE.name ..  ": " .. COLOURS.HEALING .. "Heal everyone in melee range of your target"
                        end,
                        desc = TRAITS.LIFE_PULSE.desc,
                        disabled = function()
                            return characterState.featsAndTraits.numTraitCharges.get(TRAITS.LIFE_PULSE.id) == 0
                        end,
                        func = consequences.useTrait(TRAITS.LIFE_PULSE),
                    }
                }
            },
        }
    }
end