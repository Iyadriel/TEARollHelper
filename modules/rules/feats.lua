local _, ns = ...

local character = ns.character
local rules = ns.rules

local feats = ns.resources.feats

local FEATS = feats.FEATS

local function canProcBulwarkOfHope()
    return character.hasFeat(FEATS.BULWARK_OF_HOPE)
end

rules.feats = {
    canProcBulwarkOfHope = canProcBulwarkOfHope,
}