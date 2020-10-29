local _, ns = ...

local character = ns.character
local rules = ns.rules

local feats = ns.resources.feats
local traits = ns.resources.traits

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

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

local function shouldShowPostRollUI()
    return character.hasTrait(TRAITS.FAULTLINE)
end

rules.penance = {
    canUsePenance = canUsePenance,
    calculateAttackValue = calculateAttackValue,

    shouldShowPreRollUI = shouldShowPreRollUI,
    shouldShowPostRollUI = shouldShowPostRollUI,
}