local _, ns = ...

local buffsState = ns.state.buffs.state
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS
local state = characterState.state

local function traitColour(trait)
    return COLOURS.TRAITS[trait.id] or COLOURS.TRAITS.GENERIC
end

--[[ local options = {
    order: Number,
    width: Any,
    name: Function,
    hidden: Function,
    checkBuff: Boolean,
} ]]
local function traitButton(trait, options)
    return {
        order = options.order,
        type = "execute",
        width = options.width,
        name = options.name or traitColour(trait) .. "Use " .. trait.name,
        desc = trait.desc,
        hidden = options.hidden or function()
            return not character.hasTrait(trait) or (options.checkBuff and buffsState.buffLookup.getTraitBuffs(trait))
        end,
        disabled = function()
            return state.featsAndTraits.numTraitCharges.get(trait.id) == 0
        end,
        func = consequences.useTrait(trait)
    }
end

local function traitActiveText(trait, order)
    return {
        order = order,
        type = "description",
        name = traitColour(trait) .. trait.name .. " is active.",
        hidden = function()
            return not (character.hasTrait(trait) and buffsState.buffLookup.getTraitBuffs(trait))
        end,
    }
end

ui.helpers.traitButton = traitButton
ui.helpers.traitActiveText = traitActiveText