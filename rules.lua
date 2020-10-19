local _, ns = ...

local character = ns.character
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local function calculateOffenceStat(offence, buff)
    return offence + buff
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
    return spirit + buff
end

local function canUseFeats()
    return not character.hasWeakness(WEAKNESSES.FEATLESS)
end

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.VERSATILE)
end

-- For use by other rule modules
rules.common = {
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}

rules.other = {
    canUseFeats = canUseFeats,
    shouldShowPreRollUI = shouldShowPreRollUI,
}