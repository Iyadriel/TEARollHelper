local _, ns = ...

local character = ns.character
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

-- threshold for saving is higher than the original defence threshold
local SAVE_THRESHOLD_INCREASE = 3

local function calculateGenericStat(stat, statBuff)
    return stat + statBuff
end

local function calculateOffenceStat(offence, buff)
    return calculateGenericStat(offence, buff)
end

-- damageType can be nil if defence stat is being used for a non-defensive action.
local function calculateDefenceStat(damageType, defence, buff)
    local defenceStat = defence + buff
    local feat = character.getPlayerFeat()

    if feat.passives and feat.passives.resistance and feat.passives.resistance[damageType] then
        defenceStat = defenceStat + feat.passives.resistance[damageType]
    end

    return defenceStat
end

local function calculateSpiritStat(spirit, buff)
    return calculateGenericStat(spirit, buff)
end

local function canUseFeats()
    return not character.hasWeakness(WEAKNESSES.FEATLESS)
end

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.SILAMELS_ACE) or character.hasTrait(TRAITS.VERSATILE)
end

-- For use by other rule modules
rules.common = {
    SAVE_THRESHOLD_INCREASE = SAVE_THRESHOLD_INCREASE,

    calculateGenericStat = calculateGenericStat,
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}

rules.other = {
    canUseFeats = canUseFeats,
    shouldShowPreRollUI = shouldShowPreRollUI,
}
