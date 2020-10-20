local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.rangedSave.getOptions = function(options)
    local function shouldHideRoll()
        return not rolls.state.rangedSave.threshold.get()
    end

    return {
        name = ACTION_LABELS.rangedSave,
        type = "group",
        order = options.order,
        args = {
            defendThreshold = {
                order = 0,
                name = "Defend threshold",
                type = "range",
                desc = "The defence threshold for the ally you're saving. If you do not meet this threshold, you can still reduce the damage they take.",
                min = 1,
                softMax = 20,
                max = 100,
                step = 1,
                get = rolls.state.rangedSave.threshold.get,
                set = function(info, value)
                    rolls.state.rangedSave.threshold.set(value)
                end
            },
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 1,
                hidden = function()
                    return shouldHideRoll() or not rules.meleeSave.shouldShowPreRollUI()
                end,
                args = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 0 }),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 2,
                action = ACTIONS.rangedSave,
                hidden = shouldHideRoll,
            }),
            rangedSave = {
                order = 3,
                type = "group",
                name = ACTION_LABELS.rangedSave,
                inline = true,
                hidden = function()
                    return not rolls.state.rangedSave.currentRoll.get()
                end,
                args = {
                    saveResult = {
                        order = 4,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local save = rolls.getRangedSave()

                            if save.canFullyProtect then
                                return COLOURS.ROLES.TANK .. "You can fully protect your ally."
                            elseif save.damageReduction > 0 then
                                return "You can reduce the damage your ally takes by " .. save.damageReduction .. ".|n" .. COLOURS.NOTE .. "However, you cannot act during the next player turn."
                            else
                                return COLOURS.NOTE .. "You can't reduce the damage your ally takes with this roll."
                            end
                        end
                    },
                }
            },
        },
    }
end