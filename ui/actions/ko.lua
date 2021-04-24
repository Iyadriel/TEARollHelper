local _, ns = ...

local characterState = ns.state.character
local constants = ns.constants
local turnState = ns.state.turn
local ui = ns.ui

local CONSCIOUSNESS_STATES = constants.CONSCIOUSNESS_STATES
local SPECIAL_ACTIONS = constants.SPECIAL_ACTIONS
local SPECIAL_ACTION_LABELS = constants.SPECIAL_ACTION_LABELS
local TURN_TYPES = constants.TURN_TYPES

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
                or turnState.state.type.get() ~= TURN_TYPES.PLAYER.id
        end,
        args = {
            roll = ui.modules.turn.modules.roll.getOptions({ order = 0, action = SPECIAL_ACTIONS.clingToConsciousness }),
        }
    }
end
