local _, ns = ...

local character = ns.character
local rules = ns.rules

local feats = ns.resources.feats

local FEATS = feats.FEATS

local function canUsePenance()
    return character.hasFeat(FEATS.PENANCE)
end

local function calculateAttackValue(roll, spirit, buff)
    return roll + rules.common.calculateSpiritStat(spirit, buff)
end

-- Rolling

local function shouldShowPreRollUI()
    return rules.playerTurn.shouldShowPreRollUI() or rules.other.shouldShowPreRollUI()
end

rules.penance = {
    canUsePenance = canUsePenance,
    calculateAttackValue = calculateAttackValue,

    shouldShowPreRollUI = shouldShowPreRollUI,
}