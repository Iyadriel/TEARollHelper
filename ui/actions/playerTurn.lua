local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local characterState = ns.state.character.state
local consequences = ns.consequences
local traits = ns.resources.traits
local ui = ns.ui

local TRAITS = traits.TRAITS

--[[ local options = {
    order: Number,
} ]]
ui.modules.actions.modules.playerTurn.getSharedPreRollOptions = function(options)
    return {
        useFocus = {
            order = options.order,
            type = "execute",
            name = COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.FOCUS.name,
            desc = TRAITS.FOCUS.desc,
            hidden = function()
                return not character.hasTrait(TRAITS.FOCUS) or characterState.buffLookup.getTraitBuffs(TRAITS.FOCUS)
            end,
            disabled = function()
                return characterState.featsAndTraits.numTraitCharges.get(TRAITS.FOCUS.id) == 0
            end,
            func = consequences.useFocus,
        },
        focusActive = {
            order = 0,
            type = "description",
            name = COLOURS.TRAITS.GENERIC .. TRAITS.FOCUS.name .. " is active.",
            hidden = function()
                return not (character.hasTrait(TRAITS.FOCUS) and characterState.buffLookup.getTraitBuffs(TRAITS.FOCUS))
            end,
        },
    }
end