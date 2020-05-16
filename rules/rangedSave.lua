local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS

local function calculateRangedSaveValue(roll, spirit, buff)
    return roll + rules.common.calculateSpiritStat(spirit, buff)
end

local function calculateDamageReduction(threshold, dmgRisk, saveValue, spirit)
    if saveValue >= threshold then
        return dmgRisk
    end
    local baseReduction = character.hasFeat(FEATS.WARDER) and 4 or 2
    return baseReduction + max(0, floor(spirit / 2))
end

rules.rangedSave = {
    calculateRangedSaveValue = calculateRangedSaveValue,
    calculateDamageReduction = calculateDamageReduction,
}