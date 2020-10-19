local _, ns = ...

local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS
local state = characterState.state

--[[ local options = {
    order: Number,
    name: Function,
    width: Any,
} ]]
local function traitButton(trait, options)
    return {
        order = options.order,
        type = "execute",
        width = options.width,
        name = options.name or COLOURS.TRAITS.GENERIC .. "Use " .. trait.name,
        desc = trait.desc,
        hidden = function()
            return not character.hasTrait(trait)
        end,
        disabled = function()
            return state.featsAndTraits.numTraitCharges.get(trait.id) == 0
        end,
        func = consequences.useTrait(trait)
    }
end

ui.helpers = {
    traitButton = traitButton,
}