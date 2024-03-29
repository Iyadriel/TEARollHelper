local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS
local DEFENCE_TYPES = constants.DEFENCE_TYPES

local BASE_DAMAGE_REDUCTION = 2

local function calculateRangedSaveValue(roll, spirit, buff)
    return roll + rules.common.calculateSpiritStat(spirit, buff)
end

local function canFullyProtect(defenceType, threshold, saveValue)
    return defenceType == DEFENCE_TYPES.THRESHOLD and saveValue >= threshold
end

local function calculateDamageReduction(spirit)
    return BASE_DAMAGE_REDUCTION + max(0, floor(spirit / 2))
end

local function shouldShowPreRollUI()
    return rules.other.shouldShowPreRollUI()
end

local function getRollModeModifier()
    local modifier = 0

    if character.hasFeat(FEATS.WARDER) then
        modifier = modifier + 1
    end

    return modifier
end

rules.rangedSave = {
    calculateRangedSaveValue = calculateRangedSaveValue,
    canFullyProtect = canFullyProtect,
    calculateDamageReduction = calculateDamageReduction,

    shouldShowPreRollUI = shouldShowPreRollUI,
    getRollModeModifier = getRollModeModifier,
}