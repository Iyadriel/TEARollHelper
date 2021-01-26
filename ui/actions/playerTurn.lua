local _, ns = ...

local buffsState = ns.state.buffs.state
local character = ns.character
local consequences = ns.consequences
local ui = ns.ui

local feats = ns.resources.feats

local COLOURS = TEARollHelper.COLOURS
local FEATS = feats.FEATS

--[[ local options = {
    order: Number,
} ]]
ui.modules.actions.modules.playerTurn.getSharedPreRollOptions = function(options)
    return {
        enableFocus = {
            order = options.order,
            type = "execute",
            name = COLOURS.FEATS.GENERIC .. "Enable " .. FEATS.FOCUS.name,
            desc = FEATS.FOCUS.desc,
            hidden = function()
                return not character.canUseFocus() or buffsState.buffLookup.getFeatBuff(FEATS.FOCUS)
            end,
            func = consequences.enableFocus,
        },
        focusActive = {
            order = options.order,
            type = "description",
            name = COLOURS.FEATS.GENERIC .. FEATS.FOCUS.name .. " is active.",
            hidden = function()
                return not buffsState.buffLookup.getFeatBuff(FEATS.FOCUS)
            end,
        },
    }
end