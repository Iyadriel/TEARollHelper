local _, ns = ...

local character = ns.character
local rules = ns.rules

local feats = ns.resources.feats

local FEATS = feats.FEATS

local function getNumGreaterHealSlotsToRemoveCriticalWound()
    if character.hasFeat(FEATS.TRAUMA_RESPONSE) then
        return 1
    end
    return 2
end

rules.criticalWounds = {
    getNumGreaterHealSlotsToRemoveCriticalWound = getNumGreaterHealSlotsToRemoveCriticalWound,
}