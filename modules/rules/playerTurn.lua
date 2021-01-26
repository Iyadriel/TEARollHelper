local _, ns = ...

local character = ns.character
local rules = ns.rules

local function shouldShowPreRollUI()
    return character.canUseFocus()
end

rules.playerTurn = {
    shouldShowPreRollUI = shouldShowPreRollUI,
}