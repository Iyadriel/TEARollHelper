local _, ns = ...

local actions = ns.actions
local character = ns.character
local consequences = ns.consequences
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local TRAITS = traits.TRAITS

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.meleeSave.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("meleeSave", 0)

    local function shouldHideRoll()
        return not (rolls.state.meleeSave.threshold.get() and rolls.state.meleeSave.damageRisk.get())
    end

    return {
        name = ACTION_LABELS.meleeSave,
        type = "group",
        order = options.order,
        args = {
            defenceType = sharedOptions.defenceType,
            defendThreshold = {
                order = 1,
                name = "Defend threshold",
                type = "range",
                desc = "The defence threshold for the ally you're saving. If you do not meet this threshold, you can still save them, but you will take damage.",
                min = 1,
                softMax = 20,
                max = 100,
                step = 1,
                disabled = function()
                    return rolls.state.meleeSave.defenceType.get() ~= DEFENCE_TYPES.THRESHOLD
                end,
                get = rolls.state.meleeSave.threshold.get,
                set = function(info, value)
                    rolls.state.meleeSave.threshold.set(value)
                end
            },
            damageRisk = sharedOptions.damageRisk,
            damageType = sharedOptions.damageType,
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 4,
                hidden = function()
                    return shouldHideRoll() or not rules.meleeSave.shouldShowPreRollUI()
                end,
                args = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 0 }),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 5,
                action = ACTIONS.meleeSave,
                hidden = shouldHideRoll,
            }),
            meleeSave = {
                order = 6,
                type = "group",
                name = ACTION_LABELS.meleeSave,
                inline = true,
                hidden = function()
                    return not rolls.state.meleeSave.currentRoll.get()
                end,
                args = {
                    saveDamageTaken = {
                        order = 0,
                        type = "description",
                        desc = "How much damage you take this turn",
                        fontSize = "medium",
                        name = function()
                            return actions.toString(ACTIONS.meleeSave, rolls.getMeleeSave())
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
                            local meleeSave = rolls.getMeleeSave()
                            return meleeSave.damageTaken <= 0 and meleeSave.damagePrevented <= 0
                        end,
                        func = function()
                            consequences.confirmAction(ACTIONS.meleeSave, rolls.getMeleeSave())
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
                    return not rolls.state.meleeSave.currentRoll.get() or not rules.meleeSave.shouldShowPostRollUI() or rolls.getMeleeSave().damageTaken > 0
                end,
                args = {
                    usePresenceOfVirtue = ui.helpers.traitButton(TRAITS.PRESENCE_OF_VIRTUE, {
                        order = 0,
                        hidden = function()
                            return rolls.getMeleeSave().damageTaken > 0
                        end,
                    }),
                }
            },
        },
    }
end