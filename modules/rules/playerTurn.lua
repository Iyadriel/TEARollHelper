local _, ns = ...

local character = ns.character
local rules = ns.rules

local feats = ns.resources.feats

local FEATS = feats.FEATS

local function shouldShowPreRollUI()
    return character.hasFeat(FEATS.FOCUS)
end

rules.playerTurn = {
    shouldShowPreRollUI = shouldShowPreRollUI,
}