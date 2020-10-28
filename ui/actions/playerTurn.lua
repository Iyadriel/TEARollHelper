local _, ns = ...

local traits = ns.resources.traits
local ui = ns.ui

local TRAITS = traits.TRAITS

--[[ local options = {
    order: Number,
} ]]
ui.modules.actions.modules.playerTurn.getSharedPreRollOptions = function(options)
    return {
        useFocus = ui.helpers.traitButton(TRAITS.FOCUS, {
            order = options.order,
            checkBuff = true,
        }),
        focusActive = ui.helpers.traitActiveText(TRAITS.FOCUS, 0),
    }
end