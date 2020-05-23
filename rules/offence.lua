local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local traits = ns.resources.traits

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS

local NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT = 2

local CRIT_TYPES = {
    DAMAGE = 0,
    REAPER = 1
}

-- Crits

local function getCritType()
    if character.hasFeat(FEATS.REAPER) then
        return CRIT_TYPES.REAPER
    end
    return CRIT_TYPES.DAMAGE
end

-- Core

local function getBaseDamage()
    return character.hasOffenceMastery() and 3 or 1
end

local function calculateAttackValue(roll, offence, buff)
    return roll + rules.common.calculateOffenceStat(offence, buff)
end

local function calculateAttackDmg(threshold, attackValue)
    local overkill = attackValue - threshold
    if overkill >= 0 then
        return getBaseDamage() + floor(overkill / 2)
    end
    return 0
end

local function applyCritModifier(dmg)
    return dmg * 2
end

-- Feat: Adrenaline

local function canProcAdrenaline()
    return character.hasFeat(FEATS.ADRENALINE)
end

local function hasAdrenalineProc(threshold, attackValue)
    return attackValue >= threshold + 4
end

local function calculateAdrenalineProcDmg(offence)
    return ceil(offence / 2)
end

local function applyAdrenalineProcModifier(dmg, offence)
    return dmg + calculateAdrenalineProcDmg(offence)
end

-- Feat: Blood Harvest

local function canUseBloodHarvest()
    return character.hasFeat(FEATS.BLOOD_HARVEST)
end

local function getMaxBloodHarvestSlots()
    local offence = character.getPlayerOffence()
    local numSlots = max(0, floor(offence / NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT))

    return numSlots
end

local function calculateBloodHarvestBonus(numBloodHarvestSlots)
    return numBloodHarvestSlots * 3
end

-- Feat: Mercy from Pain

local function canProcMercyFromPain()
    return character.hasFeat(FEATS.MERCY_FROM_PAIN)
end

local function hasMercyFromPainProc(dmgDealt)
    return dmgDealt >= 5
end

local function calculateMercyFromPainBonusHealing(multipleEnemiesHit)
    return multipleEnemiesHit and 4 or 2
end

-- Trait: Vindication

local function canProcVindication()
    return character.hasTrait(TRAITS.VINDICATION)
end

local function hasVindicationProc(dmgDealt)
    return dmgDealt > 0
end

local function calculateVindicationHealing(dmgDealt)
    return ceil(dmgDealt / 2)
end

-- Racial Trait: Entropic Embrace

local function canProcEntropicEmbrace()
    return character.hasRacialTrait(RACIAL_TRAITS.ENTROPIC_EMBRACE)
end

local function hasEntropicEmbraceProc(roll, threshold)
    return roll == threshold
end

local function getEntropicEmbraceDmg()
    return 3
end

rules.offence = {
    CRIT_TYPES = CRIT_TYPES,
    getCritType = getCritType,

    calculateAttackValue = calculateAttackValue,
    calculateAttackDmg = calculateAttackDmg,
    applyCritModifier = applyCritModifier,

    canProcAdrenaline = canProcAdrenaline,
    hasAdrenalineProc = hasAdrenalineProc,
    applyAdrenalineProcModifier = applyAdrenalineProcModifier,

    canUseBloodHarvest = canUseBloodHarvest,
    getMaxBloodHarvestSlots = getMaxBloodHarvestSlots,
    calculateBloodHarvestBonus = calculateBloodHarvestBonus,

    canProcMercyFromPain = canProcMercyFromPain,
    hasMercyFromPainProc = hasMercyFromPainProc,
    calculateMercyFromPainBonusHealing = calculateMercyFromPainBonusHealing,

    canProcVindication = canProcVindication,
    hasVindicationProc = hasVindicationProc,
    calculateVindicationHealing = calculateVindicationHealing,

    canProcEntropicEmbrace = canProcEntropicEmbrace,
    hasEntropicEmbraceProc = hasEntropicEmbraceProc,
    getEntropicEmbraceDmg = getEntropicEmbraceDmg
}