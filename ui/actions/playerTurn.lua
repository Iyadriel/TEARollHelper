local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs.state
local character = ns.character
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
        focusActive = {
            order = 0,
            type = "description",
            name = COLOURS.TRAITS.GENERIC .. TRAITS.FOCUS.name .. " is active.",
            hidden = function()
                return not (character.hasTrait(TRAITS.FOCUS) and buffsState.buffLookup.getTraitBuffs(TRAITS.FOCUS))
            end,
        },
    }
end