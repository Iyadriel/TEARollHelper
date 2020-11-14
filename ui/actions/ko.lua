local _, ns = ...

local constants = ns.constants
local ui = ns.ui

local SPECIAL_ACTIONS = constants.SPECIAL_ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS

--[[ local options = {
    order: Number,
    turnTypeID: String,
} ]]
ui.modules.actions.modules.KO.getOptions = function(options)
    return {
        type = "group",
        name = ACTION_LABELS.utility,
        order = options.order,
        args = {
            roll = ui.modules.turn.modules.roll.getOptions({ order = 0, action = SPECIAL_ACTIONS.clingToConsciousness }),
        }
    }
end