local _, ns = ...

local character = ns.character
local rules = ns.rules
local traits = ns.resources.traits

local TRAITS = traits.TRAITS

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.FOCUS)
end

rules.playerTurn = {
    shouldShowPreRollUI = shouldShowPreRollUI,
}