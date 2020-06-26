local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

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
        preRollArgs = utils.merge(preRollArgs, ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 1 }))
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
                includePrep = options.turnTypeID == TURN_TYPES.PLAYER.id,
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
                    mercyFromPain = {
                        name = COLOURS.FEATS.MERCY_FROM_PAIN .. FEATS.MERCY_FROM_PAIN.name,
                        type = "select",
                        desc = FEATS.MERCY_FROM_PAIN.desc,
                        order = 2,
                        values = {
                            [0] = "Inactive",
                            [rules.offence.calculateMercyFromPainBonusHealing(false)] = "Single enemy damaged",
                            [rules.offence.calculateMercyFromPainBonusHealing(true)] = "Multple enemies damaged",
                        },
                        hidden = function()
                            return not rules.offence.canProcMercyFromPain()
                        end,
                        get = state.healing.mercyFromPainBonusHealing.get,
                        set = function(info, value)
                            state.healing.mercyFromPainBonusHealing.set(value)
                        end
                    },
                    lifePulse = {
                        name = COLOURS.TRAITS.GENERIC .. TRAITS.LIFE_PULSE.name,
                        type = "toggle",
                        desc = TRAITS.LIFE_PULSE.desc,
                        order = 3,
                        hidden = function()
                            return not character.hasTrait(TRAITS.LIFE_PULSE)
                        end,
                        disabled = function()
                            return characterState.featsAndTraits.numTraitCharges.get(TRAITS.LIFE_PULSE.id) == 0
                        end,
                        get = state.healing.lifePulse.get,
                        set = function(info, value)
                            state.healing.lifePulse.set(value)
                        end
                    },
                    healing = {
                        type = "description",
                        desc = "How much you can heal for",
                        fontSize = "medium",
                        order = 4,
                        name = function()
                            local healing = rolls.getHealing(options.outOfCombat)
                            local msg = rules.healing.getMaxGreaterHealSlots() > 0 and " |n" or "" -- Only show spacing if greater heals are shown. Dirty hack

                            if healing.amountHealed > 0 then
                                local amount = tostring(healing.amountHealed)
                                local healColour = (options.outOfCombat and character.hasFeat(FEATS.MEDIC)) and COLOURS.FEATS.GENERIC or COLOURS.HEALING

                                if healing.isCrit then
                                    msg = msg .. COLOURS.CRITICAL .. "MANY HEALS!|r " .. healColour .. "You can heal everyone in line of sight for " .. amount .. " HP."
                                else
                                    if healing.lifePulse then
                                        healColour = COLOURS.TRAITS.GENERIC
                                        msg = msg .. healColour .. "You can heal everyone in melee range of your target for " .. amount .. " HP."
                                    elseif healing.usesParagon then
                                        local targets = healing.playersHealableWithParagon > 1 and " allies" or " ally"
                                        msg = msg .. healColour .. "You can heal " .. healing.playersHealableWithParagon .. targets .. " for " .. amount .. " HP."
                                    else
                                        msg = msg .. healColour .. "You can heal for " .. amount .. " HP."
                                    end
                                end
                            else
                                msg = msg .. COLOURS.NOTE .. "You can't heal anyone with this roll."
                            end

                            return msg
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
        }
    }
end