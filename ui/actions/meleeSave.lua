local _, ns = ...

local actions = ns.actions
local character = ns.character
local consequences = ns.consequences
local constants = ns.constants
local environment = ns.state.environment
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local TRAITS = traits.TRAITS

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.meleeSave.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("meleeSave", {
        thresholdLabel = "The defence threshold for the ally you're saving. If you do not meet this threshold, you can still save them, but you will take damage."
    })

    local function shouldHideRoll()
        return not (rolls.state.meleeSave.threshold.get() and rolls.state.meleeSave.damageRisk.get())
    end

    return {
        name = ACTION_LABELS.meleeSave,
        type = "group",
        order = options.order,
        hidden = function()
            return not character.canSave()
        end,
        args = {
            defenceType = sharedOptions.defenceType,
            defendThreshold = sharedOptions.defendThreshold,
            damageRisk = sharedOptions.damageRisk,
            damageType = sharedOptions.damageType,
            useHolyBulwark = ui.helpers.traitButton(TRAITS.HOLY_BULWARK, {
                order = 4,
                hidden = function()
                    local enemyId = environment.state.enemyId.get()
                    return not rules.traits.canUseHolyBulwark(enemyId) or not rolls.state.meleeSave.damageRisk.get()
                end,
                func = function()
                    consequences.useTrait(TRAITS.HOLY_BULWARK)(true)
                end,
            }),
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 5,
                hidden = function()
                    return shouldHideRoll() or not rules.meleeSave.shouldShowPreRollUI()
                end,
                args = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 0, action = ACTIONS.meleeSave }),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 6,
                action = ACTIONS.meleeSave,
                hidden = shouldHideRoll,
            }),
            meleeSave = {
                order = 7,
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
                    usePresenceOfVirtue = ui.helpers.traitToggle(ACTIONS.meleeSave, rolls.getMeleeSave, TRAITS.PRESENCE_OF_VIRTUE, {
                        order = 1,
                    }),
                    confirm = ui.helpers.confirmActionButton(ACTIONS.meleeSave, rolls.getMeleeSave, {
                        order = 2,
                    }),
                }
            },
        },
    }
end