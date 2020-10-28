local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
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
local TRAITS = traits.TRAITS

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.penance.getOptions = function(options)
    local function shouldHideRoll()
        return not state.attack.threshold.get()
    end

    local preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
        order = 1,
        hidden = function()
            return shouldHideRoll() or not rules.penance.shouldShowPreRollUI()
        end,
        args = utils.merge(
            ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 1 }),
            ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 2 })
        ),
    })

    local function getGreaterHealSliderMax()
        -- our slider breaks if the max gets set to 0 because our min is 1
        -- the slider shouldn't even be visible when max is 0 but it still breaks
        return max(characterState.healing.numGreaterHealSlots.get(), 1)
    end

    return {
        name = ACTION_LABELS.penance,
        type = "group",
        order = options.order,
        hidden = function()
            return not rules.penance.canUsePenance() or characterState.healing.numGreaterHealSlots.get() == 0
        end,
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
            penance = {
                order = 3,
                type = "group",
                name = ACTION_LABELS.penance,
                inline = true,
                hidden = function()
                    return not state.attack.currentRoll.get()
                end,
                args = {
                    actions_penance_greaterHeals = {
                        order = 0,
                        type = "range",
                        name = "Greater Heals",
                        desc = "The amount of Greater Heals to use.",
                        min = 1,
                        max = getGreaterHealSliderMax(),
                        step = 1,
                        disabled = function()
                            return characterState.healing.numGreaterHealSlots.get() == 1
                        end,
                        get = state.penance.numGreaterHealSlots.get,
                        set = function(info, value)
                            state.penance.numGreaterHealSlots.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("actions_penance_greaterHeals", {
                            max = getGreaterHealSliderMax
                        })
                    },
                    targetIsKO = {
                        order = 1,
                        type = "toggle",
                        name = "Target is unconscious",
                        desc = COLOURS.MASTERY .. "Your Spirit mastery increases healing done to KO'd targets by +3.",
                        hidden = function()
                            return not rules.healing.canUseTargetKOBonus()
                        end,
                        get = state.penance.targetIsKO.get,
                        set = function(info, value)
                            state.penance.targetIsKO.set(value)
                        end,
                    },
                    result = {
                        order = 2,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local penance = rolls.getPenance()
                            return actions.toString(ACTIONS.penance, penance)
                        end
                    },
                    confirm = {
                        order = 3,
                        type = "execute",
                        name = "Confirm",
                        desc = "Confirm that you perform the stated action, consuming any charges and buffs used.",
                        hidden = function()
                            local penance = rolls.getPenance()
                            local shouldShow = penance.dmg > 0 or penance.amountHealed > 0

                            return not shouldShow
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.penance, rolls.getPenance())
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
                    return not state.attack.currentRoll.get() or not (rolls.getPenance().dmg > 0) or not rules.penance.shouldShowPostRollUI()
                end,
                args = {
                    useFaultline = ui.helpers.traitButton(TRAITS.FAULTLINE, { order = 0 }),
                    useVindication = {
                        order = 2,
                        type = "execute",
                        width = "full",
                        name = function()
                            return COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.VINDICATION.name ..  ": " .. COLOURS.HEALING .. "Heal for " .. rolls.getPenance().vindicationHealing .. " HP"
                        end,
                        desc = TRAITS.VINDICATION.desc,
                        hidden = function()
                            return not rolls.getPenance().hasVindicationProc
                        end,
                        disabled = function()
                            return characterState.featsAndTraits.numTraitCharges.get(TRAITS.VINDICATION.id) == 0
                        end,
                        func = consequences.useTrait(TRAITS.VINDICATION),
                    }
                }
            },
        }
    }
end