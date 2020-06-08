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
    hidden: Function,
    args: Table
} ]]
ui.modules.actions.modules.playerTurn.getSharedOptions = function(options)
    local args = {
        useFocus = {
            order = 0,
            type = "execute",
            name = COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.FOCUS.name,
            desc = TRAITS.FOCUS.desc,
            hidden = function()
                return not character.hasTrait(TRAITS.FOCUS) or characterState.buffLookup.getTraitBuff(TRAITS.FOCUS)
            end,
            disabled = function()
                return characterState.featsAndTraits.numFocusCharges.get() == 0
            end,
            func = consequences.useFocus,
        },
        focusActive = {
            order = 0,
            type = "description",
            name = COLOURS.TRAITS.GENERIC .. TRAITS.FOCUS.name .. " is active.",
            hidden = function()
                return not (character.hasTrait(TRAITS.FOCUS) and characterState.buffLookup.getTraitBuff(TRAITS.FOCUS))
            end,
        },
    }

    if options.args then
        for k, v in pairs(options.args) do
            args[k] = v
        end
    end

    return {
        preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
            order = options.order,
            hidden = options.hidden,
            args = args,
        })
    }
end