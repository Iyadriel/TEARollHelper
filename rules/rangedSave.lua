local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS

local function calculateRangedSaveValue(roll, spirit, buff)
    return roll + rules.common.calculateSpiritStat(spirit, buff)
end

local function canFullyProtect(threshold, saveValue)
    return saveValue >= threshold
end

local function calculateDamageReduction(spirit)
    local baseReduction = character.hasFeat(FEATS.WARDER) and 4 or 2
    return baseReduction + max(0, floor(spirit / 2))
end

rules.rangedSave = {
    calculateRangedSaveValue = calculateRangedSaveValue,
    canFullyProtect = canFullyProtect,
    calculateDamageReduction = calculateDamageReduction,
}