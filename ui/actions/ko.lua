local _, ns = ...

local characterState = ns.state.character
local constants = ns.constants
local ui = ns.ui

local CONSCIOUSNESS_STATES = constants.CONSCIOUSNESS_STATES
local SPECIAL_ACTIONS = constants.SPECIAL_ACTIONS
local SPECIAL_ACTION_LABELS = constants.SPECIAL_ACTION_LABELS

--[[ local options = {
    order: Number,
} ]]
ui.modules.actions.modules.KO.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = function()
            return ui.iconString("Interface\\Icons\\spell_holy_painsupression") .. SPECIAL_ACTION_LABELS.clingToConsciousness
        end,
        hidden = function()
            return characterState.state.consciousness.get() ~= CONSCIOUSNESS_STATES.FADING
        end,
        args = {
            roll = ui.modules.turn.modules.roll.getOptions({ order = 0, action = SPECIAL_ACTIONS.clingToConsciousness }),
        }
    }
end